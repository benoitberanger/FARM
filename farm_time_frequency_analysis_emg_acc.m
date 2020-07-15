function TFA = farm_time_frequency_analysis_emg_acc( data, cfg )
% FARM_TIME_FREQUENCY_ANALYSIS_EMG_ACC
% 1)   get filtered EMG timeseries
% 1.5) get filtered ACC timeseries ("cfg.acc_regex" is required)
% 2)   get EMG envelope, so the low (<30Hz) frequency can be captured
% 3)   downsample @ 500Hz for faster computation
% 4)   use ft_freqanalysis() using "multi-taper method"
% 5)   post-processing : for each channels & averaged channels
%   a) power average across frequency
%   b) power average across time
%   c) power @ peak frequency
%
% SYNTAX
%       TFA = FARM_TIME_FREQUENCY_ANALYSIS_EMG_ACC( data, cfg )
%
% INPUTS
%       - data : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - cfg  : check in the code of the function
%
% NOTES
%
%
% See also ft_freqanalysis

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

% TFA paramters
minmax_foi = ft_getopt(cfg,'minmax_foi', [2 15]); % (Hz) [min max] frequency of interest
dF         = ft_getopt(cfg,        'dF',    0.1); % (Hz) output frequency resolution
dT         = ft_getopt(cfg,        'dT',    0.1); % (s)  output time resolution
nCycle     = ft_getopt(cfg,    'nCycle',   10.0); % int  number of cycles per frequency range

% Frequency range selection
rangeF     = ft_getopt(cfg,    'rangeF',    1.0); % (Hz) range of frequency average around the peak frequency


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


%% TFA

data_TFA            = [];
data_TFA.trial{1}   = new_timeseries;
data_TFA.time {1}   = new_time;
data_TFA.fsample    = new_fsample;
data_TFA.label      = channel_name;
data_TFA.sampleinfo = [1 size(data_TFA.trial{1},2)];

cfg_TFA             = [];
cfg_TFA.method      = 'mtmconvol'; % time-frequency analysis on any time series trial data using the 'multitaper method' (MTM)
cfg_TFA.output      = 'pow';       % power-spectra
cfg_TFA.taper       = 'hanning';   % hanning window
cfg_TFA.pad         = 'maxperlen'; % (default)
cfg_TFA.toi         = (new_time(1) : dT : new_time(end)); % timepoints of interest
cfg_TFA.foi         = minmax_foi(1) : dF : minmax_foi(2); % frequency  of interest
cfg_TFA.t_ftimwin   = nCycle ./cfg_TFA.foi;               % taper size for each foi // here we use nCycle/foi, so there is constant amoung of datapoints per foi

TFA = ft_freqanalysis(cfg_TFA, data_TFA);

TFA.powspctrm(isnan(TFA.powspctrm)) = 0; % for convinience


%% Post-processing
% Important note : here, 'avg' means 'average across channels'

dN = rangeF / dF / 2; % We take rangeF (Hz) around the peak frequency

for chan = 1 : length(channel_name)
    
    TFA.power_Tmean(chan,:)  = mean( TFA.powspctrm(chan,:,:), 3);                    % (nChan x nFreq   )
    TFA.power_Fmean(chan,:)  = mean( TFA.powspctrm(chan,:,:), 2);                    % (nChan x nSample )
    [~,I] = max(TFA.power_Tmean(chan,:));
    TFA.peakfreq (chan)    = TFA.freq(I);                                            % (nChan x 1       )
    TFA.peakpower(chan,:)  = mean( squeeze( TFA.powspctrm(chan, I-dN:I+dN,:) ) , 1); % (nChan x nSamples)
    
end % chan

TFA.  powspctrm_avg = squeeze( mean( TFA.powspctrm  , 1 ) );
TFA.power_Tmean_avg =          mean( TFA.power_Tmean, 1 )  ;
TFA.power_Fmean_avg =          mean( TFA.power_Fmean, 1 )  ;
[~,I]               = max(TFA.power_Tmean_avg);
TFA.peakfreq_avg    = TFA.freq(I);
TFA.peakpower_avg   = mean( TFA.powspctrm_avg(I-dN:I+dN,:) , 1 );


end % function
