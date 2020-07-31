function coh = farm_coherence_analysis_emg_acc( data, cfg )
% FARM_COHERENCE_ANALYSIS_EMG_ACC
% 1)   get filtered EMG timeseries
% 1.5) get filtered ACC timeseries ("cfg.acc_regex" is required)
% 2)   get EMG envelope, so the low (<30Hz) frequency can be captured
% 3)   downsample @ 500Hz for faster computation
% 4)   split the whole timeseries into sub-segments of 60s
% 5)   use ft_freqanalysis() to get the Fourier coefficients
% 6)   ft_connectivityanalysis() using 'coh' for coherence analysis
%
% SYNTAX
%       coh = FARM_COHERENCE_ANALYSIS_EMG_ACC( data, cfg )
%
% INPUTS
%       - data : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - cfg  : All the default parameters are contained in the sub-functions
%
% NOTES
%
%
% See also farm.tfa.prepare_emg_acc ft_connectivityanalysis ft_freqanalysis

if nargin==0, help(mfilename('fullpath')); return; end


%% Get EMG/ACC prepared data

data_emg_acc = farm.tfa.prepare_emg_acc( data, cfg );


%% Coherence

coh = farm.tfa.perform_coherence_analysis( data_emg_acc, cfg );


end % function
