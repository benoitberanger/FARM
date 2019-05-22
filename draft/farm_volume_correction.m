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


% %% Prepare where to store the data
% 
current_trial = length(data.trial);
% next_trial    = current_trial + 1;
% 
% data.trial{next_trial,1} = zeros(size(data.trial{1}));


%% Main

nChannel = length(data.cfg.channel);

for iChannel = 1 : nChannel
    %% Upsample
    
    % Get raw data
    input_channel = data.trial{current_trial}(iChannel, :);
    
    % Upsample
    [ ~, upsampled_channel ] = farm_upsample( data.time{1}, input_channel, fsample, interpfactor );
    
    
    %% Prepare good slice-segement
    
    padding = 10; % samples, only useful for the phase-shift
    
    slice_list = data.slice_info.good_slice_idx;
    
    % Get segment
    good_slice_segement = zeros( length(slice_list), round(sdur * fsample * interpfactor) + padding );
    for iSlice = 1 : length(slice_list)
        good_slice_segement(iSlice,:) = upsampled_channel( slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + round(sdur * fsample * interpfactor) - 1 + padding/2 );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t        = round_error(slice_list) / sdur / (fsample*interpfactor);
    good_slice_segement = farm_phase_shift( good_slice_segement, delta_t );
    
    % Remove padding
    good_slice_segement = good_slice_segement(:, 1+padding/2 : end-padding/2);
    
    % Visualization : uncomment bellow
    % figure('Name','good_slice_segement','NumberTitle','off'); image(good_slice_segement,'CDataMapping','scaled'), colormap(gray(256));
    
    
    %% Prepare last slice-segement
    
    padding = 10; % samples, only useful for the phase-shift
    
    slice_list = data.slice_info.lastslice_idx;
    
    % Get segment
    last_slice_segement = zeros( length(slice_list), round(sdur * fsample * interpfactor) + padding );
    for iSlice = 1 : length(slice_list)
        last_slice_segement(iSlice,:) = upsampled_channel( slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + round(sdur * fsample * interpfactor) - 1 + padding/2 );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t        = round_error(slice_list) / sdur / (fsample*interpfactor);
    last_slice_segement = farm_phase_shift( last_slice_segement, delta_t );
    
    % Remove padding
    last_slice_segement = last_slice_segement(:, 1+padding/2 : end-padding/2);
    
    % Visualization : uncomment bellow
    % figure('Name','last_slice_segement','NumberTitle','off'); image(last_slice_segement,'CDataMapping','scaled'), colormap(gray(256));
    
    
    %% Prepare first slice-segement
    
    padding = 10; % samples, only useful for the phase-shift
    
    slice_list = data.slice_info.firstslice_idx;
    
    % Get segment
    first_slice_segement = zeros( length(slice_list), round(sdur * fsample * interpfactor) + padding );
    for iSlice = 1 : length(slice_list)
        first_slice_segement(iSlice,:) = upsampled_channel( slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + round(sdur * fsample * interpfactor) - 1 + padding/2 );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t        = round_error(slice_list) / sdur / (fsample*interpfactor);
    first_slice_segement = farm_phase_shift( first_slice_segement, delta_t );
    
    % Remove padding
    first_slice_segement = first_slice_segement(:, 1+padding/2 : end-padding/2);
    
    % Visualization : uncomment bellow
    % figure('Name','first_slice_segement','NumberTitle','off'); image(first_slice_segement,'CDataMapping','scaled'), colormap(gray(256));
    
    
    %% Prepare volume-segement
    
    padding = 10; % samples, only useful for the phase-shift
    
    slice_list = data.slice_info.lastslice_idx;
    
    % Get segment
    volume_segement = zeros( length(slice_list), round(dtime * fsample * interpfactor) + padding );
    for iSlice = 1 : length(slice_list)
        volume_segement(iSlice,:) = upsampled_channel( slice_onset(slice_list(iSlice)) + round(sdur * fsample * interpfactor) - padding/2 : slice_onset(slice_list(iSlice)) + round( sdur * fsample * interpfactor ) + round( dtime * fsample * interpfactor ) - 1 + padding/2 );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t         = round_error(slice_list) / sdur / (fsample*interpfactor);
    volume_segement = farm_phase_shift( volume_segement, delta_t );
    
    % Remove padding
    volume_segement = volume_segement(:, 1+padding/2 : end-padding/2);
    
    % Visualization : uncomment bellow
    % figure('Name','volume_segement','NumberTitle','off'); image(volume_segement,'CDataMapping','scaled'), colormap(gray(256));
    
    
    %% Prepare last_slice + volume_segement + fist_slice
    
    padding = 10; % samples, only useful for the phase-shift
    
    slice_list = data.slice_info.lastslice_idx;
    
    % Get segment
    around_slice_segement = zeros( length(slice_list), round(sdur * fsample * interpfactor)*2 + round(dtime * fsample * interpfactor) + padding );
    for iSlice = 1 : length(slice_list)
        around_slice_segement(iSlice,:) = upsampled_channel( slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + round( sdur * fsample * interpfactor) * 2 + round( dtime * fsample * interpfactor) - 1 + padding/2 );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t         = round_error(slice_list) / sdur / (fsample*interpfactor);
    around_slice_segement = farm_phase_shift( around_slice_segement, delta_t );
    
    % Remove padding
    around_slice_segement = around_slice_segement(:, 1+padding/2 : end-padding/2);
    
    % Visualization : uncomment bellow
    % figure('Name','around_slice_segement','NumberTitle','off'); image(around_slice_segement,'CDataMapping','scaled'), colormap(gray(256));
    

    %% Prepare 2 consecutive good slice
    
    padding = 10; % samples, only useful for the phase-shift
    
    slice_list = data.slice_info.good_slice_idx;
    
    % Get volume-segment
    consecutive_good_segement = zeros( length(slice_list), round(sdur * fsample * interpfactor)*2 + padding );
    for iSlice = 1 : length(slice_list)
        consecutive_good_segement(iSlice,:) = upsampled_channel( slice_onset(slice_list(iSlice)) - padding/2 : slice_onset(slice_list(iSlice)) + round( sdur * fsample * interpfactor) * 2 - 1 + padding/2 );
    end
    
    % Apply phase-shift to conpensate the rounding error
    delta_t         = round_error(slice_list) / sdur / (fsample*interpfactor);
    consecutive_good_segement = farm_phase_shift( consecutive_good_segement, delta_t );
    
    % Remove padding
    consecutive_good_segement = consecutive_good_segement(:, 1+padding/2 : end-padding/2);
    
    % Visualization : uncomment bellow
    % figure('Name','consecutive_good_segement','NumberTitle','off'); image(consecutive_good_segement,'CDataMapping','scaled'), colormap(gray(256));
    
    
   %%
   
   lastfirst_segement = [last_slice_segement first_slice_segement];
   
   mean_lastfirst_segment         = mean(lastfirst_segement);
   mean_consecutive_good_segement = mean(consecutive_good_segement);
   
   figure
   
   hold on
   plot(mean_lastfirst_segment)
   plot(mean_consecutive_good_segement)

   diff = mean_lastfirst_segment - mean_consecutive_good_segement;
   plot(diff)
   
   
%     %% Determine where is the preparation-segment + overlap with slice-segment
%     % We could determine the preparation segement using dtime, but it would not take
%     % into account the overlap with slice-segment.
%     % Here is a method to automaticly determine the preparation-segment + overlap with slice-segment
%     
%     mean_around_slice_segement     = mean(around_slice_segement);
%     mean_consecutive_good_segement = mean(consecutive_good_segement);
%     
%     % Start of preparation segement
%     %----------------------------------------------------------------------
%     
%     % First pass, find where the substracted_mean start to diverge
%     start_prepseg_window_rough = round( (sdur - dtime) * fsample * interpfactor ) : round( (sdur + dtime) * fsample * interpfactor );
%     substracted_mean_start = mean_around_slice_segement(start_prepseg_window_rough) - mean_consecutive_good_segement(start_prepseg_window_rough);
%     substracted_mean_start = abs(substracted_mean_start);
%     substracted_mean_start = substracted_mean_start / max(substracted_mean_start);
%     start_prepseg_rightlimit = start_prepseg_window_rough(1) + find( abs(substracted_mean_start) > 0.1, 1, 'first' );
%         
%     % Second pass, find where the mean is closer from 0 and left of 'start_prepseg_rightlimit'
%     start_prepseg_window_focused = round( (sdur - dtime) * fsample * interpfactor ) : start_prepseg_rightlimit;
%     prepseg_close_close_from_zero_and_upperlimit = mean_around_slice_segement(start_prepseg_window_focused);
%     prepseg_close_close_from_zero_and_upperlimit = abs(prepseg_close_close_from_zero_and_upperlimit);
%     % The loop below will find where is the closest point to 0 and left of start_prepseg_upperlimit
%     prev_value = Inf;
%     for i = length(prepseg_close_close_from_zero_and_upperlimit) : -1 : 1
%         current_value = prepseg_close_close_from_zero_and_upperlimit(i);
%         if current_value > prev_value
%             break
%         else
%             prev_value = current_value;
%         end
%         assert( i ~= 1, 'oh...' )
%     end
%     start_prepseg = i-1;
%     start_prepseg = start_prepseg_window_focused(1) + start_prepseg;
%     
%     % Visualize the strat_prepseg : uncomment bellow
%     %**********************************************************************
%         figure
%         hold on
%         plot(mean_around_slice_segement    ,'DisplayName','mean_around_slice_segement'    )
%         plot(mean_consecutive_good_segement,'DisplayName','mean_consecutive_good_segement')
%         plot([start_prepseg start_prepseg], [min(mean_around_slice_segement) max(mean_around_slice_segement)], 'black', 'LineWidth',2, 'DisplayName','start_prepseg_zero')
%         lgd = legend;
%         set(lgd,'Interpreter','none');
%     %**********************************************************************
    
%     % End of preparation segement
%     %----------------------------------------------------------------------
%     mean_around_slice_segement     = fliplr(mean_around_slice_segement);
%     mean_consecutive_good_segement = fliplr(mean_consecutive_good_segement);
%     close all
%     % First pass, find where the substracted_mean end to diverge
%     end_prepseg_window_rough = round( (sdur - dtime*0.1) * fsample * interpfactor ) : round( (sdur + dtime) * fsample * interpfactor );
%     substracted_mean_end = mean_around_slice_segement(end_prepseg_window_rough) - mean_consecutive_good_segement(end_prepseg_window_rough);
%     hold on
%     plot(mean_around_slice_segement(end_prepseg_window_rough))
%     plot(mean_consecutive_good_segement(end_prepseg_window_rough))
%     plot(substracted_mean_end)
%     substracted_mean_end = abs(substracted_mean_end);
%     substracted_mean_end = substracted_mean_end / max(substracted_mean_end);
%     end_prepseg_rightlimit = end_prepseg_window_rough(1) + find( abs(substracted_mean_end) > 0.1, 1, 'first' );
%     
%     % Second pass, find where the mean is closer from 0 and left of 'end_prepseg_rightlimit'
%     end_prepseg_window_focused = round( (sdur - dtime) * fsample * interpfactor ) : end_prepseg_rightlimit;
%     prepseg_close_close_from_zero_and_upperlimit = mean_around_slice_segement(end_prepseg_window_focused);
%     prepseg_close_close_from_zero_and_upperlimit = abs(prepseg_close_close_from_zero_and_upperlimit);
%     % The loop below will find where is the closest point to 0 and left of end_prepseg_upperlimit
%     prev_value = Inf;
%     for i = length(prepseg_close_close_from_zero_and_upperlimit) : -1 : 1
%         current_value = prepseg_close_close_from_zero_and_upperlimit(i);
%         if current_value > prev_value
%             break
%         else
%             prev_value = current_value;
%         end
%         assert( i ~= 1, 'oh...' )
%     end
%     end_prepseg = i-1;
%     end_prepseg = end_prepseg_window_focused(1) + end_prepseg;
%     
%     % Visualize the end_prepseg : uncomment bellow
%     %**********************************************************************
%     figure
%     hold on
%     plot(mean_around_slice_segement    ,'DisplayName','mean_around_slice_segement'    )
%     plot(mean_consecutive_good_segement,'DisplayName','mean_consecutive_good_segement')
%     % plot([end_prepseg end_prepseg], [min(mean_around_slice_segement) max(mean_around_slice_segement)], 'black', 'LineWidth',2, 'DisplayName','end_prepseg_zero')
%     set(lgd,'Interpreter','none');
%     %**********************************************************************
    
end % iChannel


end % function

% function new_x = phase_correction(x,y)
% 
% % take the FFT
% X=fft(x-mean(x));
% Y=fft(y-mean(y));
% 
% % Determine the max value and max point.
% % This is where the sinusoidal
% % is located. See Figure 2.
% [~,idx_x] = max(abs(X));
% [~,idx_y] = max(abs(Y));
% % determine the phase difference
% % at the maximum point.
% px = angle(X(idx_x));
% py = angle(Y(idx_y));
% phase_lag = py - px;
% 
% %%
% ind = 1:round(numel(x)/2);
% new_x(ind) = abs(x(ind)).*exp(1i*angle(x(ind))+1i*+phase_lag);
% ind = round(numel(x)/2)+1:numel(x);
% new_x(ind) = abs(x(ind)).*exp(1i*angle(x(ind))+1i*-phase_lag);
% % plot(x-new_x)
% new_x = real(new_x);
% 
% end % function
% 
% function phase_lag = phase_diff(x,y)
% 
% % take the FFT
% X=fft(x-mean(x));
% Y=fft(y-mean(y));
% 
% % Determine the max value and max point.
% % This is where the sinusoidal
% % is located. See Figure 2.
% [~,idx_x] = max(abs(X));
% [~,idx_y] = max(abs(Y));
% % determine the phase difference
% % at the maximum point.
% px = angle(X(idx_x));
% py = angle(Y(idx_y));
% phase_lag = py - px;
% 
% end % function
