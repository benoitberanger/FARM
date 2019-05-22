function data = farm_slice_correction( data )
% FARM_SLICE_CORRECTION will use the slices index prepared by farm_pick_slice_for_template,
% and select, for each slice, the surrounding slices with the highest correlation.
% When the selection is done, prepare the template and perform the substraction.
%
% Ref : Van der Meer, J. N., Tijssen, M. A. J., Bour, L. J., van Rootselaar, A. F., & Nederveen, A. J. (2010).
%       Robust EMG–fMRI artifact reduction for motion (FARM).
%       Clinical Neurophysiology, 121(5), 766–776.
%       https://doi.org/10.1016/j.clinph.2009.12.035
%

if nargin==0, help(mfilename); return; end


%% Paramters

nKeep = 12; % number of best candidates to keep


%% Retrive some variables already computed

interpfactor   = data.interpfactor;
fsample        = data.fsample;
sdur           = data.sdur;
dtime          = data.dtime;
slice_onset    = round(data.slice_onset * interpfactor); % phase-shift will be applied to conpensate the rounding error
round_error    = data.round_error;


%% Main

nChannel = length(data.cfg.channel);

for iChannel = 1 : nChannel
    %% Upsample
    
    % Get raw data
    input_channel = data.trial{1}(iChannel, :);
    
    % Upsample
    [ ~, upsampled_channel ] = farm_upsample( data.time{1}, input_channel, fsample, interpfactor );
    
    
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
    
    % Remove padding
    slice_segement = slice_segement(:, 1+padding/2 : end-padding/2);
    
    % Visualization : uncomment bellow
    % figure('Name','slice_segement','NumberTitle','off'); image(slice_segement,'CDataMapping','scaled'), colormap(gray(256));
    
    
    %% Prepare template
    % For each slice, find best candidates using higher correlations with
    % slice groups prepared by farm_pick_slice_for_template
    
    for iSlice = 1 : length(slice_list)
        slice_target_data    = slice_segement(iSlice,:);                                    % this is the slice we want to correct
        slice_candidate_idx  = data.slice_info.slice_idx_for_template(iSlice,:);            % index of slices candidate
        slice_candidate_data = slice_segement(slice_candidate_idx,:);                       % data  of slices candidate
        correlation          = farm_correlation(slice_target_data, slice_candidate_data);   % correlation between target slice and all the candidates
        [~, order] = sort(correlation,'descend');                                           % sort the candidates correlation
        template             = mean(slice_segement(slice_candidate_idx(order(1:nKeep)),:)); % keep the bests, and average them : this is our template
        scaling = slice_target_data*template'/(template*template');                         % use the "power" ratio as scling factor
        template = scaling * template;                                                      % scale the template so it fits more the target
        %         figure
        %         subplot 211
        %         hold on
        %         plot(slice_target_data)
        %         plot(template)
        %         subplot 212
        %         hold on
        %         plot(slice_target_data-template)
        %%
    end
    
    
end % iChannel


end % function
