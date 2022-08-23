function TFA = perform_time_frequency_analysis( data, cfg )
% PERFORM_TIME_FREQUENCY_ANALYSIS use ft_freqanalysis() using "multi-taper method"
%
% SYNTAX
%       TFA = farm.tfa.PERFORM_TIME_FREQUENCY_ANALYSIS( data, cfg )
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

% TFA paramters
foi    = ft_getopt(cfg,'       foi', [2 8] ); % (Hz) [min max] frequency of interest
dF     = ft_getopt(cfg,        'dF',    0.1); % (Hz) output frequency resolution
dT     = ft_getopt(cfg,        'dT',    0.1); % (s)  output time resolution
nCycle = ft_getopt(cfg,    'nCycle',   10  ); % int  number of cycles per frequency range


%% TFA

cfg_TFA             = [];
cfg_TFA.method      = 'mtmconvol'; % time-frequency analysis on any time series trial data using the 'multitaper method' (MTM)
cfg_TFA.output      = 'pow';       % power-spectra
cfg_TFA.taper       = 'hanning';   % hanning window
cfg_TFA.pad         = 'maxperlen'; % (default)
cfg_TFA.toi         = (data.time{1}(1) : dT : data.time{1}(end)); % timepoints of interest
cfg_TFA.foi         =           foi(1) : dF : foi(2);             % frequency  of interest
cfg_TFA.t_ftimwin   = nCycle ./cfg_TFA.foi;                       % taper size for each foi // here we use nCycle/foi, so there is constant amoung of datapoints per foi

TFA = ft_freqanalysis(cfg_TFA, data);

if isfield(data,'info'), TFA.info = data.info; end


end % function
