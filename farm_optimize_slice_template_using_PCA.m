function data = farm_optimize_slice_template_using_PCA( data )
% FARM_OPTIMIZE_SLICE_TEMPLATE_USING_PCA
%
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


%% Retrive some variables already computed

interpfactor   = data.interpfactor;
fsample        = data.fsample;
sdur           = data.sdur;
dtime          = data.dtime;
slice_onset    = round(data.slice_onset * interpfactor); % phase-shift will be applied to conpensate the rounding error
round_error    = data.round_error;


%% Parameters

% Time section for the PCA computation.
% PCA will be computed over 'time_section', for adaptability
time_section = 60; % in seconds

padding = 10; % samples, only useful for the phase-shift

marker_vector = data.slice_info.marker_vector; % use all slices


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

sdur_sample = round(sdur * fsample * interpfactor);

nChannel = length(data.cfg.channel);

for iChannel = 1 : nChannel
    
    fprintf('[%s]: Computing PCA on channel %d/%d - using matlab built-in svd() function... \n', mfilename, iChannel, nChannel)
    
    slice_list = data.slice_info.marker_vector;
    
    % Upsample : slice_segement (raw data)
    %----------------------------------------------------------------------
    
    % Get raw data
    input_channel = data.vol_clean(iChannel, :);
    
    % Upsample
    [ upsampled_channel, upsampled_time ] = farm_resample( input_channel, data.time{1}, fsample, interpfactor );
    
    % Get segment
    slice_segement = zeros( length(slice_list), sdur_sample + padding );
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + sdur_sample - 1 + padding/2;
        slice_segement(iSlice,:) = upsampled_channel( window );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t        = round_error(slice_list) / sdur / (fsample*interpfactor);
    slice_segement = farm_phase_shift( slice_segement, delta_t );
    
    % Remove padding
    slice_segement = slice_segement(:, 1+padding/2 : end-padding/2);
    
    % Go back to (1 x sample), it's mandatory for volume artifact substraction
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) : slice_onset(slice_list(iSlice)) + sdur_sample - 1;
        upsampled_channel( window ) = slice_segement(iSlice,:);
    end
    
    
    % Upsample : artifact_segement
    %----------------------------------------------------------------------
    
    % Get raw data
    artifact_channel = data.vol_noise(iChannel, :);
    
    % Upsample
    upsampled_artifact = farm_resample( artifact_channel, data.time{1}, fsample, interpfactor );
    
    % Get segment
    artifact_segement = zeros( length(slice_list), sdur_sample + padding );
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + sdur_sample - 1 + padding/2;
        artifact_segement(iSlice,:) = upsampled_artifact( window );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t           = round_error(slice_list) / sdur / (fsample*interpfactor);
    artifact_segement = farm_phase_shift( artifact_segement, delta_t );
    
    % Remove padding
    artifact_segement = artifact_segement(:, 1+padding/2 : end-padding/2);
    
    % Go back to (1 x sample), it's mandatory for volume artifact substraction
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) : slice_onset(slice_list(iSlice)) + sdur_sample - 1;
        upsampled_artifact( window ) = artifact_segement(iSlice,:);
    end
    
    % Substract raw data with the slice templates
    %----------------------------------------------------------------------
    
    substracted_channel = upsampled_channel - upsampled_artifact;
    
    % Now reshape to (iSlice x sample)
    substracted_segement = zeros(size(slice_segement));
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) : slice_onset(slice_list(iSlice)) + sdur_sample - 1;
        substracted_segement( iSlice, : ) = substracted_channel(window);
    end
    
    % Output: sections of this vector will replaced
    clean_channel = substracted_channel;
    noise_channel = upsampled_artifact;
    
    
    for iSection = 1 : nSection
        
        
        % Get slice list in this section
        slice_list = slice_section{iSection};
        
        
        %% Prepare residuals for PCA, section by section
        
        substracted_segement_section = substracted_segement(slice_list,:);
        
        substracted_segement_section = ft_preproc_highpassfilter( substracted_segement_section, fsample*interpfactor, 70 ); % from fastr
        
        % Visualization : uncomment bellow
        % figure('Name','substracted_segement_section','NumberTitle','off'); image(substracted_segement_section,'CDataMapping','scaled'), colormap(gray(256));
        
        
        %% Prepare PCA
        
        % Use orientation (samples x variables) for matlab built'in functions
        substracted_segement_section = substracted_segement_section';
        
        mean_artifact = mean(substracted_segement_section,2);
        
        % center data (remove mean) for each slice segement, for PCA
        substracted_segement_section = substracted_segement_section - mean(substracted_segement_section);
        
        
        %% PCA
        
        [~, Eload, EVal] = farm_pca_calc(substracted_segement_section);
        vairance_explained = 100*EVal/sum(EVal); % in percent (%)
        
        % Visualization : uncomment bellow
        % figure('Name','first 50 PCs','NumberTitle','off'); image(Eload(:,1:50),'CDataMapping','scaled'), colormap(gray(256));
        
        fprintf('[%s]: Variance explained for the first 20 PCs (%%) : %s \n', mfilename, num2str(vairance_explained(1:20)','%.1f, ') )
        
        nComponent = sum(vairance_explained > 5);
        fprintf('[%s]: Selecting components with more than 5%% of variance : nComponent = %d \n', mfilename, nComponent)
        
        
        %% Scale components to data before substraction
        
        PC = Eload(:,1:nComponent);
        
        % Scale all PCs so all of them have the same [min max]
        PeakToPeak = max(PC) - min(PC);
        PC         = PC ./ PeakToPeak * PeakToPeak(1); % scaled to the first (1) component
        
        fitted_residual = zeros(size(substracted_segement_section));
        
        for iSlice = 1 : length(slice_list)
            fitted_residual(:,iSlice) = PC * ( PC \ substracted_segement_section(:,iSlice) );
        end
        
        % Visualization : uncomment bellow
        % figure('Name','fitted_residual','NumberTitle','off'); image(fitted_residual,'CDataMapping','scaled'), colormap(gray(256));
        
        
        %% Substraction
        
        % Change back from ( slice x sample(slice) ) to (1 x sample) timeserie
        for iSlice = 1 : length(slice_list)
            window = slice_onset(slice_list(iSlice)) : slice_onset(slice_list(iSlice)) + sdur_sample -1;
            clean_channel( window ) = substracted_segement(slice_list(iSlice),:) - fitted_residual(:,iSlice)' - mean_artifact';
            noise_channel( window ) =    artifact_segement(slice_list(iSlice),:) + fitted_residual(:,iSlice)' + mean_artifact';
        end
        
        
    end % iSection
    
    
    %% Substraction
    
    fprintf('[%s]: Saving data & noise \n', mfilename)
    
    % Downsample and save
    data.pca_clean(iChannel, :) = farm_resample( clean_channel, upsampled_time, fsample * interpfactor, 1/interpfactor );
    data.pca_noise(iChannel, :) = farm_resample( noise_channel, upsampled_time, fsample * interpfactor, 1/interpfactor );
    
    
end % iChannel


end % function
