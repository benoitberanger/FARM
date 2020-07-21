function data_emg_acc = prepare_emg_acc( data, cfg )
% PREPARE_EMG_ACC function will :
% 1)   get filtered EMG timeseries
% 1.5) get filtered ACC timeseries ("cfg.acc_regex" is required)
% 2)   get EMG envelope, so the low (<30Hz) frequency can be captured
% 3)   downsample @ 500Hz for faster computation
%
% SYNTAX
%       data_emg_acc = farm.tfa.PREPARE_EMG_ACC( data, cfg )
%
% INPUTS
%       - data : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - cfg  : check in the code of the function
%
% NOTES
%
%
% See also farm_time_frequency_analysis_emg_acc

if nargin==0, help(mfilename('fullpath')); return; end


%% Input parsing

% EMG filtering options
emg_stage  = ft_getopt(cfg, 'emg_stage' , 'pca_clean'); % char
emg_filter = ft_getopt(cfg, 'emg_filter', +[30 250]  ); % (Hz)
emg_order  = ft_getopt(cfg, 'emg_order'              ); % int
cfg        = ft_checkconfig(cfg, 'required', {'emg_regex'}); % required
emg_regex  = ft_getopt(cfg, 'emg_regex'              );

% ACC filtering options
acc_stage  = ft_getopt(cfg, 'acc_stage' , 'raw'     ); % char
acc_filter = ft_getopt(cfg, 'acc_filter', +[ 2  15] ); % (Hz)
acc_order  = ft_getopt(cfg, 'acc_order' , 2         ); % int
acc_regex  = ft_getopt(cfg, 'acc_regex'             ); % NOT required


if ~isempty(acc_regex)
    use_ACC = 1;
else
    use_ACC = 0;
end

%% Get filtered timeseries

[ timeseries_emg, channel_idx_emg, channel_name_emg, ~ ] = farm_get_timeseries( data, emg_regex, emg_stage, emg_filter, emg_order);
envelope_emg = farm_emg_envelope( timeseries_emg, data.fsample );

if use_ACC
    [ timeseries_acc, ~, channel_name_acc, ~ ] = farm_get_timeseries( data, acc_regex, acc_stage, acc_filter, acc_order );
    timeseries   = [envelope_emg    ; timeseries_acc  ];
    channel_name = [channel_name_emg; channel_name_acc];
else
    timeseries   = envelope_emg    ;
    channel_name = channel_name_emg;
end


%% Downsample

time           = (0:size(timeseries,2)-1)/data.fsample;
new_fsample    = 500; % Hz
[ new_timeseries, new_time ] = farm.resample( timeseries, time, data.fsample, new_fsample/data.fsample );

% Normalize because EMG & ACC do not have the same range of values
new_timeseries = farm.normalize_range( new_timeseries );

% EMG range is [ 0 +1] due to envelope
% ACC range is [-1 +1]
new_timeseries(channel_idx_emg+1:end,:) = new_timeseries(channel_idx_emg+1:end,:)/2;
% Now ACC range is [-0.5 +0.5] => same peak to peak amplitude as EMG
% This scaling reduce the weight of ACC in the average power across channels


%% Output

data_emg_acc            = [];
data_emg_acc.trial{1}   = new_timeseries;
data_emg_acc.time {1}   = new_time;
data_emg_acc.fsample    = new_fsample;
data_emg_acc.label      = channel_name;
data_emg_acc.sampleinfo = [1 size(data_emg_acc.trial{1},2)];


end % function
