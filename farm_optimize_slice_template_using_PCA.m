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
slice_onset    = round(data.slice_onset * interpfactor); % phase-shift will be applied to conpensate the rounding error
round_error    = data.round_error;


%% Parameters

padding = 10; % samples, only useful for the phase-shift

slice_list = data.slice_info.marker_vector;


%% Main

nChannel = length(data.cfg.channel);

for iChannel = 1 : nChannel
    %% Upsample : slice_segement (raw data)
    
    % Get raw data
    input_channel = data.trial{1}(iChannel, :);
    
    % Upsample
    [ upsampled_time, upsampled_channel ] = farm_resample( data.time{1}, input_channel, fsample, interpfactor );
    
    
    %% Prepare slice-segement
    
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
    
    
    %% Upsample : artifact_segement
    
    % Get raw data
    artifact_channel = data.artifact_template(iChannel, :);
    
    % Upsample
    [ ~, upsampled_artifact ] = farm_resample( data.time{1}, artifact_channel, fsample, interpfactor );
    
    
    %% Prepare artifact-segement
    
    % Get segment
    artifact_segement = zeros( length(slice_list), round(sdur * fsample * interpfactor) + padding );
    for iSlice = 1 : length(slice_list)
        artifact_segement(iSlice,:) = upsampled_artifact( slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + round(sdur * fsample * interpfactor) - 1 + padding/2 );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t           = round_error(slice_list) / sdur / (fsample*interpfactor);
    artifact_segement = farm_phase_shift( artifact_segement, delta_t );
    
    % Remove padding
    artifact_segement = artifact_segement(:, 1+padding/2 : end-padding/2);

    
    %% Substract raw data with the slice templates, ready for PCA
    
    substracted_segement = slice_segement - artifact_segement;
    
    % Visualization : uncomment bellow
    % figure('Name','substracted_segement = slice_segement - artifact_segement','NumberTitle','off'); image(substracted_segement,'CDataMapping','scaled'), colormap(gray(256));
    
    
    %% Prepare PCA
    
    % Use orientation (samples x variables) for matlab built'in functions
    substracted_segement = substracted_segement';
    
    mean_artifact = mean(substracted_segement,2);
    
    % center data (remove mean) for each slice segement, for PCA using SVD
    substracted_segement = substracted_segement - mean(substracted_segement);
    
    
    %% PCA
    
    fprintf('[%s]: Computing PCA on channel %d/%d using matlab built-in svd() function... (it can take a while) \n', mfilename, iChannel, nChannel)
    tic, [~, Eload, EVal] = farm_pca_calc(substracted_segement); toc
    vairance_explained = 100*EVal/sum(EVal); % in percent (%)
    clear EVal % free memory
    
    % Visualization : uncomment bellow
    % figure('Name','first 50 PCs','NumberTitle','off'); image(Eload(:,1:50),'CDataMapping','scaled'), colormap(gray(256));
    
    fprintf('[%s]: Variance explained for the first 20 PCs (%%) : %s \n', mfilename, num2str(vairance_explained(1:20)','%.1f, ') )
    
    nComponent = sum(vairance_explained > 5);
    fprintf('[%s]: Selecting components with more than 5%% of variance : nComponent=%d \n', mfilename, nComponent)
    
    
    %% Scale components to data before substraction
    
    PC = Eload(:,1:nComponent);
    clear Eload % free memory
    
    % Scale all PCs so all of them have the same [min max]
    PeakToPeak = max(PC) - min(PC);
    PC         = PC ./ PeakToPeak * PeakToPeak(1); % scaled to the first (1) component
    
    fitted_residual = zeros(size(substracted_segement));
    
    for iSlice = 1 : length(slice_list)
        fitted_residual(:,iSlice) = PC * ( PC \ substracted_segement(:,iSlice) );
    end
    
    % Visualization : uncomment bellow
    % figure('Name','fitted_residual','NumberTitle','off'); image(fitted_residual,'CDataMapping','scaled'), colormap(gray(256));
    
    
    %% Substraction
    
    fprintf('[%s]: Saving data & noise \n', mfilename)
    
    % Use orientation (variables x samples)
    substracted_segement = substracted_segement';
    
    clean_channel = upsampled_channel;
    noise_channel = upsampled_artifact;
    
    % Change back from ( slice x sample(slice) ) to (1 x sample) timeserie
    for iSlice = 1 : length(slice_list)
        clean_channel( slice_onset(slice_list(iSlice)) : slice_onset(slice_list(iSlice)) + round(sdur * fsample * interpfactor) -1 ) = substracted_segement(iSlice,:) - fitted_residual(:,iSlice)' - mean_artifact';
        noise_channel( slice_onset(slice_list(iSlice)) : slice_onset(slice_list(iSlice)) + round(sdur * fsample * interpfactor) -1 ) = artifact_segement   (iSlice,:) + fitted_residual(:,iSlice)' + mean_artifact';
    end
    
    % Downsample and save
    [ ~, data.trial{1}(iChannel, :) ] = farm_resample( upsampled_time, clean_channel, fsample * interpfactor, 1/interpfactor );
    [ ~, data.   noise(iChannel, :) ] = farm_resample( upsampled_time, noise_channel, fsample * interpfactor, 1/interpfactor );
    
    
end % iChannel


end % function
