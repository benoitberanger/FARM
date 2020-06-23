function data = farm_volume_correction( data )
% FARM_VOLUME_CORRECTION will replace the datapoints corresponding to dtime
% with interpolated data from the neighboring slice-segments
%
% SYNTAX
%       data = FARM_VOLUME_CORRECTION( data )
%
% INPUTS
%       - data : see <a href="matlab: help farm_check_data">farm_check_data</a>
%
%
%**************************************************************************
% Ref : Van der Meer, J. N., Tijssen, M. A. J., Bour, L. J., van Rootselaar, A. F., & Nederveen, A. J. (2010).
%       Robust EMG–fMRI artifact reduction for motion (FARM).
%       Clinical Neurophysiology, 121(5), 766–776.
%       https://doi.org/10.1016/j.clinph.2009.12.035
%

if nargin==0, help(mfilename('fullpath')); return; end


%% Checks

narginchk(1,1)

farm_check_data( data )


%% Load

[ data, skip ]= farm.io.intermediate.load(data,mfilename);
if skip, return, end


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

% Pre-allocate output
data.vol_clean = zeros( size(data.trial{1}) );
data.vol_noise = zeros( size(data.trial{1}) );
    
nChannel = length(data.cfg.channel);

for iChannel = data.selected_channels_idx'
    
    fprintf('[%s]: Performing volume correction on channel %d - %s \n', mfilename, iChannel, data.label{iChannel})
    
    slice_list = data.slice_info.marker_vector;
    
    % Upsample : slice_segment (raw data)
    %----------------------------------------------------------------------
    
    % Get raw data
    input_channel = data.initial_hpf(iChannel, :);
    
    % Upsample
    [ upsampled_channel, upsampled_time ] = farm.resample( input_channel, data.time{1}, fsample, interpfactor );
    
    % Get segment
    slice_segment = zeros( length(slice_list), round(sdur * fsample * interpfactor) + padding );
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + sdur_sample - 1 + padding/2;
        slice_segment(iSlice,:) = upsampled_channel( window );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t       = round_error(slice_list) / sdur / (fsample*interpfactor);
    slice_segment = farm.phase_shift( slice_segment, delta_t );
    
    % Remove padding
    slice_segment = slice_segment(:, 1+padding/2 : end-padding/2);
    
    % Go back to (1 x sample)
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) : slice_onset(slice_list(iSlice)) + sdur_sample - 1;
        upsampled_channel( window ) = slice_segment(iSlice,:);
    end
    
    % Upsample : artifact_segment
    %----------------------------------------------------------------------
    
    % Get raw data
    artifact_channel = data.artifact_template(iChannel, :);
    
    % Upsample
    upsampled_artifact = farm.resample( artifact_channel, data.time{1}, fsample, interpfactor );
    
    % Get segment
    artifact_segment = zeros( length(slice_list), round(sdur * fsample * interpfactor) + padding );
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + sdur_sample - 1 + padding/2;
        artifact_segment(iSlice,:) = upsampled_artifact( window );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t          = round_error(slice_list) / sdur / (fsample*interpfactor);
    artifact_segment = farm.phase_shift( artifact_segment, delta_t );
    
    % Remove padding
    artifact_segment = artifact_segment(:, 1+padding/2 : end-padding/2);
    
    % Go back to (1 x sample)
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) : slice_onset(slice_list(iSlice)) + sdur_sample - 1;
        upsampled_artifact( window ) = artifact_segment(iSlice,:);
    end
    
    
    %% Replace the volume-segment including some overlap by interpolated data
    
    lastslice_list = data.slice_info.lastslice_idx;
    for iSlice = 1 : length(lastslice_list)
        window = slice_onset(lastslice_list(iSlice)) + sdur_sample-dtime_sample : slice_onset(lastslice_list(iSlice)) + sdur_sample+dtime_sample;
        upsampled_channel ( window ) = 0;
        upsampled_artifact( window ) = 0;
    end
    
    
    %% Go to (nSlice x nSample)
    
    slice_list = data.slice_info.marker_vector;
    
    % Get segment
    slice_segment = zeros( length(slice_list), round(sdur * fsample * interpfactor) + padding );
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + sdur_sample - 1 + padding/2;
        slice_segment(iSlice,:) = upsampled_channel( window );
    end
    
    % Get segment
    artifact_segment = zeros( length(slice_list), round(sdur * fsample * interpfactor) + padding );
    for iSlice = 1 : length(slice_list)
        window = slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + sdur_sample - 1 + padding/2;
        artifact_segment(iSlice,:) = upsampled_artifact( window );
    end
    
    
    %% Save
    
    fprintf('[%s]:     Saving volume correction on channel %d - %s \n', mfilename, iChannel, data.label{iChannel})
    
    % Apply phase-shift to conpensate the rounding error
    delta_t           = -round_error(slice_list) / sdur / (fsample*interpfactor);
    slice_segment    = farm.phase_shift( slice_segment   , delta_t );
    artifact_segment = farm.phase_shift( artifact_segment, delta_t );
    
    % Remove padding
    slice_segment    = slice_segment   (:, 1+padding/2 : end-padding/2);
    artifact_segment = artifact_segment(:, 1+padding/2 : end-padding/2);
    
    vol_clean = upsampled_channel;
    vol_noise = upsampled_artifact;
    
    % (iSlice x sample) -> (1 x sample)
    for iSlice = 1 : length(slice_list)
        window            = slice_onset(slice_list(iSlice)): slice_onset(slice_list(iSlice)) + sdur_sample - 1;
        vol_clean(window) =    slice_segment(iSlice,:);
        vol_noise(window) = artifact_segment(iSlice,:);
    end
    
    % Downsample
    data.vol_clean(iChannel, :) = farm.resample( vol_clean, upsampled_time, fsample * interpfactor, 1/interpfactor );
    data.vol_noise(iChannel, :) = farm.resample( vol_noise, upsampled_time, fsample * interpfactor, 1/interpfactor );
    
    
end % iChannel


%% Save

farm.io.intermediate.save(data,mfilename,'vol_clean','vol_noise')


end % function
