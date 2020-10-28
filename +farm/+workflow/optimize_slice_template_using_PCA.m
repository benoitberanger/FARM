function data = optimize_slice_template_using_PCA( data, time_section )
% OPTIMIZE_SLICE_TEMPLATE_USING_PCA
%
% SYNTAX
%       farm.workflow.OPTIMIZE_SLICE_TEMPLATE_USING_PCA( data, time_section )
%
% INPUTS
%       - data         : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - time_section : timeseries will be splitted in sections where the PCA will be computed
%                        this strategy increases the PCA adapatabilty
%
% DEFAULTS
%       - time_section : 60 seconds
%
%
%**************************************************************************
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

if nargin==0, help(mfilename('fullpath')); return; end


%% Checks

narginchk(1,2)

farm_check_data( data )


%% Load

[ data, skip ]= farm.io.intermediate.load(data,mfilename);
if skip, return, end


%% Parameters

% Time section for the PCA computation.
% PCA will be computed over 'time_section', for adaptability
if ~exist('time_section','var')
    time_section = 60; % in seconds
end

padding = 10; % samples, only useful for the phase-shift

marker_vector = data.slice_info.marker_vector; % use all slices


%% Retrive some variables already computed

interpfactor   = data.interpfactor;
fsample        = data.fsample;
sdur           = data.sdur;
dtime          = data.dtime;
slice_onset    = round(data.slice_onset * interpfactor); % phase-shift will be applied to conpensate the rounding error
round_error    = data.round_error;


%% Prepare sections : ~1min of data where we performe the PCA residuals removal

scan_duration = ( data.slice_onset(end)+(2*sdur+dtime)*fsample - data.slice_onset(1) ) / fsample; % 1 extra slice
nSection      = round( scan_duration/time_section );

nSlice_total = length(marker_vector);

nSlice_section = nSlice_total / nSection;

slice_section = cell(1,nSection);
for iSection = 1 : nSection
    slice_section{iSection} = marker_vector( 1 + round((iSection-1)*nSlice_section) : round((iSection)*nSlice_section) );
end


%% Main

% Which points to get ?
start_onset = round(slice_onset(1  )                 );
stop_onset  = round(slice_onset(end) + 1*sdur*fsample);

sdur_sample = round(sdur * fsample * interpfactor);

% Pre-allocate output
data.sub_template = zeros( size(data.trial{1}) );
data.pca_clean    = zeros( size(data.trial{1}) );
data.pca_noise    = zeros( size(data.trial{1}) );

for iChannel = data.selected_channels_idx(:)'
    
    fprintf('[%s]: Computing PCA on channel %d - %s - using matlab built-in svd() function... \n', farm.io.mfilename, iChannel, data.label{iChannel})
    
    slice_list = data.slice_info.marker_vector;
    
    % Upsample : slice_segment (raw data)
    %----------------------------------------------------------------------
    
    % Get raw data
    input_channel = data.vol_clean(iChannel, :);
    
    % Upsample
    [ upsampled_channel, upsampled_time ] = farm.resample( input_channel, data.time{1}, fsample, interpfactor );
    
    % Get segment
    slice_segment = zeros( length(slice_list), sdur_sample + padding );
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + sdur_sample - 1 + padding/2;
        slice_segment(iSlice,:) = upsampled_channel( window );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t        = round_error(slice_list) / sdur / (fsample*interpfactor);
    slice_segment = farm.phase_shift( slice_segment, delta_t );
    
    % Remove padding
    slice_segment = slice_segment(:, 1+padding/2 : end-padding/2);
    
    % Go back to (1 x sample), it's mandatory for volume artifact substraction
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) : slice_onset(slice_list(iSlice)) + sdur_sample - 1;
        upsampled_channel( window ) = slice_segment(iSlice,:);
    end
    
    
    % Upsample : artifact_segment
    %----------------------------------------------------------------------
    
    % Get raw data
    artifact_channel = data.vol_noise(iChannel, :);
    
    % Upsample
    upsampled_artifact = farm.resample( artifact_channel, data.time{1}, fsample, interpfactor );
    
    % Get segment
    artifact_segment = zeros( length(slice_list), sdur_sample + padding );
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + sdur_sample - 1 + padding/2;
        artifact_segment(iSlice,:) = upsampled_artifact( window );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t           = round_error(slice_list) / sdur / (fsample*interpfactor);
    artifact_segment = farm.phase_shift( artifact_segment, delta_t );
    
    % Remove padding
    artifact_segment = artifact_segment(:, 1+padding/2 : end-padding/2);
    
    % Go back to (1 x sample), it's mandatory for volume artifact substraction
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) : slice_onset(slice_list(iSlice)) + sdur_sample - 1;
        upsampled_artifact( window ) = artifact_segment(iSlice,:);
    end
    
    % Substract raw data with the slice templates
    %----------------------------------------------------------------------
    
    substracted_channel     = upsampled_channel - upsampled_artifact;
    lpf_substracted_channel = ft_preproc_highpassfilter( substracted_channel, fsample*interpfactor, 70 );
    
    % Now reshape to (iSlice x sample)
    substracted_segment = zeros(size(slice_segment));
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) : slice_onset(slice_list(iSlice)) + sdur_sample - 1;
        substracted_segment( iSlice, : ) = lpf_substracted_channel(window);
    end
    
    % Output: sections of this vector will replaced
    clean_channel = upsampled_channel;
    noise_channel = upsampled_artifact;
    
    % Do not perform substraction on data outside the volume parkers
    % This will keep the data outside the fMRI scan intact
    clean_channel(start_onset:stop_onset) = substracted_channel(start_onset:stop_onset);
    
    
    for iSection = 1 : nSection
        
        % Get slice list in this section
        slice_list = slice_section{iSection};
        
        
        %% Prepare residuals for PCA, section by section
        
        substracted_segment_section = substracted_segment(slice_list,:);
        
        % Visualization : uncomment bellow
        % figure('Name','substracted_segment_section','NumberTitle','off'); image(substracted_segment_section,'CDataMapping','scaled'), colormap(gray(256));
        
        
        %% Prepare PCA
        
        % Use orientation (samples x variables) for matlab built'in functions
        substracted_segment_section = substracted_segment_section';
        
        mean_artifact = mean(substracted_segment_section,2);
        
        % center data (remove mean) for each slice segment, for PCA
        substracted_segment_section = substracted_segment_section - mean(substracted_segment_section);
        
        
        %% PCA
        
        [~, Eload, EVal] = farm.pca_calc(substracted_segment_section);
        vairance_explained = 100*EVal/sum(EVal); % in percent (%)
        
        % Visualization : uncomment bellow
        % figure('Name','first 50 PCs','NumberTitle','off'); image(Eload(:,1:50),'CDataMapping','scaled'), colormap(gray(256));
        
        fprintf('[%s]: Variance explained for the first 20 PCs (%%) : %s \n', farm.io.mfilename, num2str(vairance_explained(1:20)','%.1f, ') )
        
        nComponent = sum(vairance_explained > 5);
        fprintf('[%s]: Selecting components with more than 5%% of variance : nComponent = %d \n', farm.io.mfilename, nComponent)
        
        
        %% Scale components to data before substraction
        
        PC = Eload(:,1:nComponent);
        
        % Scale all PCs so all of them have the same [min max]
        PeakToPeak = max(PC) - min(PC);
        PC         = PC ./ PeakToPeak * PeakToPeak(1); % scaled to the first (1) component
        
        fitted_residual = zeros(size(substracted_segment_section));
        
        for iSlice = 1 : length(slice_list)
            fitted_residual(:,iSlice) = PC * ( PC \ substracted_segment_section(:,iSlice) );
        end
        
        % Visualization : uncomment bellow
        % figure('Name','fitted_residual','NumberTitle','off'); image(fitted_residual,'CDataMapping','scaled'), colormap(gray(256));
        
        
        %% Substraction
        
        % Change back from ( slice x sample(slice) ) to (1 x sample) timeserie
        for iSlice = 1 : length(slice_list)
            window = slice_onset(slice_list(iSlice)) : slice_onset(slice_list(iSlice)) + sdur_sample -1;
            clean_channel( window ) = substracted_segment(slice_list(iSlice),:) - fitted_residual(:,iSlice)' - mean_artifact';
            noise_channel( window ) =    artifact_segment(slice_list(iSlice),:) + fitted_residual(:,iSlice)' + mean_artifact';
        end
        
        
    end % iSection
    
    
    slice_list = data.slice_info.marker_vector;
    
    substracted_segment_save = zeros( length(slice_list), sdur_sample + padding );
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + sdur_sample - 1 + padding/2;
        substracted_segment_save( iSlice, : ) = substracted_channel(window);
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t                  = -round_error(slice_list) / sdur / (fsample*interpfactor);
    substracted_segment_save = farm.phase_shift( substracted_segment_save, delta_t );
    
    % Remove padding
    substracted_segment_save = substracted_segment_save(:, 1+padding/2 : end-padding/2);
    
    upsampled_substracted = substracted_channel;
    
    % Go back to (1 x sample), it's mandatory for volume artifact substraction
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) : slice_onset(slice_list(iSlice)) + sdur_sample - 1;
        upsampled_substracted( window ) = substracted_segment_save(iSlice,:);
    end
    
    
    %% Substraction
    
    fprintf('[%s]: Saving data & noise on channel %d - %s \n', farm.io.mfilename, iChannel, data.label{iChannel})
    
    % Downsample and save
    data.sub_template(iChannel, :) = farm.resample( upsampled_substracted, upsampled_time, fsample * interpfactor, 1/interpfactor );
    data.pca_clean   (iChannel, :) = farm.resample( clean_channel        , upsampled_time, fsample * interpfactor, 1/interpfactor );
    data.pca_noise   (iChannel, :) = farm.resample( noise_channel        , upsampled_time, fsample * interpfactor, 1/interpfactor );
    
    
end % iChannel


%% Save

farm.io.intermediate.save(data,mfilename,'sub_template','pca_clean','pca_noise')


end % function
