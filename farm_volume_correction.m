function data = farm_volume_correction( data )
% FARM_VOLUME_CORRECTION will replace the datapoints corresponding to dtime
% with interpolated data from the neighboring slice-segements
%
% Ref : Van der Meer, J. N., Tijssen, M. A. J., Bour, L. J., van Rootselaar, A. F., & Nederveen, A. J. (2010).
%       Robust EMG–fMRI artifact reduction for motion (FARM).
%       Clinical Neurophysiology, 121(5), 766–776.
%       https://doi.org/10.1016/j.clinph.2009.12.035
%

if nargin==0, help(mfilename); return; end

%% Paramters

padding = 10; % samples, only useful for the phase-shift


%% Retrive some variables already computed

interpfactor   = data.interpfactor;
fsample        = data.fsample;
sdur           = data.sdur;
dtime          = data.dtime;
slice_onset    = round(data.slice_onset * interpfactor); % phase-shift will be applied to conpensate the rounding error
round_error    = data.round_error;


%% Main

sdur_sample  = round(sdur  * fsample * interpfactor);
dtime_sample = round(dtime * fsample * interpfactor);

nChannel = length(data.cfg.channel);

for iChannel = 1 : nChannel
    
    fprintf('[%s]: Performing volume correction on channel %d/%d \n', mfilename, iChannel, nChannel)
    
    slice_list = data.slice_info.marker_vector;
    
    % Upsample : slice_segement (raw data)
    %----------------------------------------------------------------------
    
    % Get raw data
    input_channel = data.trial{1}(iChannel, :);
    
    % Upsample
    [ upsampled_channel, upsampled_time ] = farm_resample( input_channel, data.time{1}, fsample, interpfactor );
    
    % Get segment
    slice_segement = zeros( length(slice_list), round(sdur * fsample * interpfactor) + padding );
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + sdur_sample - 1 + padding/2;
        slice_segement(iSlice,:) = upsampled_channel( window );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t        = round_error(slice_list) / sdur / (fsample*interpfactor);
    slice_segement = farm_phase_shift( slice_segement, delta_t );
    
    
    % Upsample : artifact_segement
    %----------------------------------------------------------------------
    
    % Get raw data
    artifact_channel = data.artifact_template(iChannel, :);
    
    % Upsample
    upsampled_artifact = farm_resample( artifact_channel, data.time{1}, fsample, interpfactor );
    
    % Get segment
    artifact_segement = zeros( length(slice_list), round(sdur * fsample * interpfactor) + padding );
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + sdur_sample - 1 + padding/2;
        artifact_segement(iSlice,:) = upsampled_artifact( window );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t           = round_error(slice_list) / sdur / (fsample*interpfactor);
    artifact_segement = farm_phase_shift( artifact_segement, delta_t );
    
    
    %% Replace the volume-segement including some overlap by interpolated data
    
    lastslice_list = data.slice_info.lastslice_idx;
    for iSlice = 1 : length(lastslice_list)
        slice_segement   (lastslice_list(iSlice),sdur_sample-dtime_sample:end) = 0;
        artifact_segement(lastslice_list(iSlice),sdur_sample-dtime_sample:end) = 0;
    end
    
    
    %% Save
    
    fprintf('[%s]:     Saving volume correction on channel %d/%d \n', mfilename, iChannel, nChannel)
    
    % Apply phase-shift to conpensate the rounding error
    delta_t           = -round_error(slice_list) / sdur / (fsample*interpfactor);
    slice_segement    = farm_phase_shift( slice_segement   , delta_t );
    artifact_segement = farm_phase_shift( artifact_segement, delta_t );
    
    % Remove padding
    slice_segement    = slice_segement   (:, 1+padding/2 : end-padding/2);
    artifact_segement = artifact_segement(:, 1+padding/2 : end-padding/2);
    
    vol_clean  = upsampled_channel;
    vol_noise = upsampled_artifact;
    
    % (iSlice x sample) -> (1 x sample)
    for iSlice = 1 : length(slice_list)
        window            = slice_onset(slice_list(iSlice)): slice_onset(slice_list(iSlice)) + sdur_sample - 1;
        vol_clean(window) =    slice_segement(iSlice,:);
        vol_noise(window) = artifact_segement(iSlice,:);
    end
    
    % Downsample
    data.vol_clean(iChannel, :) = farm_resample( vol_clean, upsampled_time, fsample * interpfactor, 1/interpfactor );
    data.vol_noise(iChannel, :) = farm_resample( vol_noise, upsampled_time, fsample * interpfactor, 1/interpfactor );
    
    
end % iChannel


end % function