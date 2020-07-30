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
%       - cfg  : All the default parameters are contained in the sub-functions
%
% NOTES
%
%
% See also ft_freqanalysis farm.tfa.prepare_emg_acc farm.tfa.perform_time_frequency_analysis farm.tfa.postprocessing

if nargin==0, help(mfilename('fullpath')); return; end


%% Get EMG/ACC prepared data

data_emg_acc = farm.tfa.prepare_emg_acc( data, cfg );


%% TFA

TFA = farm.tfa.perform_time_frequency_analysis( data_emg_acc, cfg );


%% Post-processing

TFA = farm.tfa.postprocessing( TFA, cfg );


end % function
