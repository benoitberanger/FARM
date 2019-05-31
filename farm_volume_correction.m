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

overlap = [0.10 0.10]; % ratio of dtime [left right] that will be also interpolated

padding = 10; % samples, only useful for the phase-shift


%% Retrive some variables already computed

interpfactor   = data.interpfactor;
fsample        = data.fsample;
sdur           = data.sdur;
dtime          = data.dtime;
slice_onset    = round(data.slice_onset * interpfactor); % phase-shift will be applied to conpensate the rounding error
round_error    = data.round_error;


sequence           = data.sequence;
volume_event       = ft_filter_event(data.cfg.event,'value',data.volume_marker_name);
onset_first_volume = volume_event(1).sample;
nVol               = length(volume_event);


sdur_sample    = round(sdur  * fsample * interpfactor);
dtime_sample   = round(dtime * fsample * interpfactor);


%% Main

nChannel = length(data.cfg.channel);

for iChannel = 1 : nChannel
    
    fprintf('[%s]: Performing volume correction on channel %d/%d \n', mfilename, iChannel, nChannel)
    
    
    %% Raw data : Prepare last_slice + volume_segement + fist_slice
    
    % Get raw data
    target_channel = data.trial{1}(iChannel, :);
    
    % Upsample
    [ upsampled_channel, upsampled_time ] = farm_resample( target_channel, data.time{1}, fsample, interpfactor );
    
    slice_list = data.slice_info.lastslice_idx;
    
    % Get segment
    around_slice_segement = zeros( length(slice_list), sdur_sample*2 + dtime_sample + padding );
    for iSlice = 1 : length(slice_list)
        around_slice_segement(iSlice,:) = upsampled_channel( slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + sdur_sample * 2 + dtime_sample - 1 + padding/2 );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t         = round_error(slice_list) / sdur / (fsample*interpfactor);
    around_slice_segement = farm_phase_shift( around_slice_segement, delta_t );
    
    % Visualization : uncomment bellow
    % figure('Name','around_slice_segement','NumberTitle','off'); image(around_slice_segement,'CDataMapping','scaled'), colormap(gray(256));
    
    
    %% Tempalte data : Prepare last_slice + volume_segement + fist_slice
    
    % Get raw data
    artifact_channel = data.artifact_template(iChannel, :);
    
    % Upsample
    upsampled_artifact = farm_resample( artifact_channel, data.time{1}, fsample, interpfactor );
    
    slice_list = data.slice_info.lastslice_idx;
    
    % Get segment
    around_slice_artifact = zeros( length(slice_list), sdur_sample*2 + dtime_sample + padding );
    for iSlice = 1 : length(slice_list)
        around_slice_artifact(iSlice,:) = upsampled_artifact( slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + sdur_sample * 2 + dtime_sample - 1 + padding/2 );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t               = round_error(slice_list) / sdur / (fsample*interpfactor);
    around_slice_artifact = farm_phase_shift( around_slice_artifact, delta_t );
    
    % Visualization : uncomment bellow
    % figure('Name','around_slice_segement','NumberTitle','off'); image(around_slice_artifact,'CDataMapping','scaled'), colormap(gray(256));
    
    
    %% Replace the volume-segement including some overlap by interpolated data
    
    overlap_sample = round( overlap * dtime_sample );
    
    window_replacement = 1+padding/2 + sdur_sample - overlap_sample(1) : 1+padding/2 + sdur_sample + dtime_sample + overlap_sample(2);
    
    value_left_window  = around_slice_artifact(:, window_replacement(1  )-1 ); % b(1)
    value_right_window = around_slice_artifact(:, window_replacement(end)+1 ); % b(2)
    
    gradient_leftright = (value_right_window - value_left_window) / length(window_replacement); % a = b(2) - b(1) / n
    
    replacement = gradient_leftright * (1 : length(window_replacement)) + value_left_window; % y = a*t + b
    
    around_slice_segement(:, window_replacement ) = replacement;
    around_slice_artifact(:, window_replacement ) = replacement;
    
    % Visualization : uncomment bellow
    % figure('Name','around_slice_segement','NumberTitle','off'); image(around_slice_artifact,'CDataMapping','scaled'), colormap(gray(256));
    
    
    %% Save
    
    fprintf('[%s]:     Saving volume correction on channel %d/%d \n', mfilename, iChannel, nChannel)
    
    % Apply phase-shift to conpensate the rounding error
    delta_t               = -round_error(slice_list) / sdur / (fsample*interpfactor);
    around_slice_segement = farm_phase_shift( around_slice_segement, delta_t );
    around_slice_artifact = farm_phase_shift( around_slice_artifact, delta_t );
    
    % Remove padding
    around_slice_segement = around_slice_segement(:, 1+padding/2 : end-padding/2);
    around_slice_artifact = around_slice_artifact(:, 1+padding/2 : end-padding/2);
    
    slice_segment  = upsampled_channel;
    slice_artifact = upsampled_artifact;
    
    % (iSlice x sample) -> (1 x sample)
    for iSlice = 1 : length(slice_list)
        window                 = slice_onset(slice_list(iSlice)): slice_onset(slice_list(iSlice)) + sdur_sample * 2 + dtime_sample - 1;
        slice_segment (window) = around_slice_segement(iSlice,:);
        slice_artifact(window) = around_slice_artifact(iSlice,:);
    end
    
    % Downsample
    data.vol_clean(iChannel, :) = farm_resample( slice_segment , upsampled_time, fsample * interpfactor, 1/interpfactor );
    data.vol_noise(iChannel, :) = farm_resample( slice_artifact, upsampled_time, fsample * interpfactor, 1/interpfactor );
    
    
end % iChannel


end % function
