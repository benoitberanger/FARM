function data = farm_compute_slice_template( data )
% FARM_COMPUTE_SLICE_TEMPLATE will use the slices index prepared by farm_pick_slice_for_template,
% and select, for each slice, the surrounding slices with the highest correlation.
% When the selection is done, prepare the template.
%
% Ref : Van der Meer, J. N., Tijssen, M. A. J., Bour, L. J., van Rootselaar, A. F., & Nederveen, A. J. (2010).
%       Robust EMG–fMRI artifact reduction for motion (FARM).
%       Clinical Neurophysiology, 121(5), 766–776.
%       https://doi.org/10.1016/j.clinph.2009.12.035
%
%       R.K. Niazy, C.F. Beckmann, G.D. Iannetti, J.M. Brady, and S.M. Smith
%       Removal of FMRI environment artifacts from EEG data using optimal basis sets
%       NeuroImage 28 (2005) 720 – 737
%       https://doi.org/10.1016/j.neuroimage.2005.06.067
%
if nargin==0, help(mfilename); return; end


%% Paramters

nKeep = 12; % number of best candidates to keep


%% Retrive some variables already computed

interpfactor   = data.interpfactor;
fsample        = data.fsample;
sdur           = data.sdur;
slice_onset    = round(data.slice_onset * interpfactor); % phase-shift will be applied to conpensate the rounding error
round_error    = data.round_error;


%% Main

nChannel = length(data.cfg.channel);

for iChannel = 1 : nChannel
    %% Upsample
    
    % Get raw data
    input_channel = data.trial{1}(iChannel, :);
    
    % Upsample
    [ upsampled_channel, upsampled_time ] = farm_resample( input_channel, data.time{1}, fsample, interpfactor );
    
    
    %% Prepare slice-segement
    
    padding = 10; % samples, only useful for the phase-shift
    
    slice_list = data.slice_info.marker_vector;
    
    % Get segment
    slice_segement = zeros( length(slice_list), round(sdur * fsample * interpfactor) + padding );
    for iSlice = 1 : length(slice_list)
        slice_segement(iSlice,:) = upsampled_channel( slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + round(sdur * fsample * interpfactor) - 1 + padding/2 );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t        = round_error(slice_list) / sdur / (fsample*interpfactor);
    slice_segement = farm_phase_shift( slice_segement, delta_t );
    
    % Visualization : uncomment bellow
    % figure('Name','slice_segement','NumberTitle','off'); image(slice_segement,'CDataMapping','scaled'), colormap(gray(256));
    
    
    %% Prepare template
    % For each slice, find best candidates using higher correlations with
    % slice groups prepared by farm_pick_slice_for_template
    
    slice_template = zeros( size(slice_segement) );
    
    fprintf('[%s]: Preparing slice template @ channel %d/%d ... \n', mfilename, iChannel, nChannel)
    
    % Here the indexes of samples are a bit complicated : the input 'slice_segement' is padded with some extra samples,
    % but only the inner part (when you remove padding) has to be used for the correlation & scaling.
    
    for iSlice = 1 : length(slice_list)
        slice_target_data        = slice_segement(iSlice,1+padding/2 : end-padding/2);              % this is the slice we want to correct
        slice_candidate_idx      = data.slice_info.slice_idx_for_template(iSlice,:);                % index of slices candidate
        slice_candidate_data     = slice_segement(slice_candidate_idx,1+padding/2 : end-padding/2); % data  of slices candidate
        correlation              = farm_correlation(slice_target_data, slice_candidate_data);       % correlation between target slice and all the candidates
        [~, order]               = sort(correlation,'descend');                                     % sort the candidates correlation
        template                 = mean(slice_segement(slice_candidate_idx(order(1:nKeep)),:));     % keep the bests, and average them : this is our template
        scaling                  = slice_target_data*template(1+padding/2 : end-padding/2)'/...
            (template(1+padding/2 : end-padding/2)*template(1+padding/2 : end-padding/2)');         % use the "power" ratio as scaling factor [ R.K. Niazy et al. (2005) ]
        slice_template(iSlice,:) = scaling * template;                                              % scale the template so it fits more the target
    end
    
    % Visualization : uncomment bellow
    % figure('Name','slice_template','NumberTitle','off'); image(slice_template,'CDataMapping','scaled'), colormap(gray(256));
    
    
    %% Save the tempalte data
    
    fprintf('[%s]:    Saving slice template @ channel %d/%d ... \n', mfilename, iChannel, nChannel)
    
    % Apply phase-shift to conpensate the rounding error
    delta_t          = -round_error(slice_list) / sdur / (fsample*interpfactor);
    slice_template   = farm_phase_shift( slice_template  , delta_t );
    
    % Remove padding
    slice_segement   = slice_segement(:, 1+padding/2 : end-padding/2); %#ok<NASGU>
    slice_template   = slice_template(:, 1+padding/2 : end-padding/2);
    
    % Pre-allocation
    artifact_channel = upsampled_channel;
    
    % Change back from ( slice x sample(slice) ) to (1 x sample) timeserie
    for iSlice = 1 : length(slice_list)
        artifact_channel( slice_onset(slice_list(iSlice)) : slice_onset(slice_list(iSlice)) + round(sdur * fsample * interpfactor) -1 ) = slice_template(iSlice,:);
    end
    
    % Downsample and save
    data.artifact_template(iChannel, :) = farm_resample( artifact_channel, upsampled_time, fsample * interpfactor, 1/interpfactor );
    
    
end % iChannel


end % function
