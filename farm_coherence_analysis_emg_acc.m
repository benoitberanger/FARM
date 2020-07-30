function coh = farm_coherence_analysis_emg_acc( data, cfg )

% FARM_TIME_FREQUENCY_ANALYSIS_EMG_ACC
% 1)   get filtered EMG timeseries
% 1.5) get filtered ACC timeseries ("cfg.acc_regex" is required)
% 2)   get EMG envelope, so the low (<30Hz) frequency can be captured
% 3)   downsample @ 500Hz for faster computation
% 4)   use ft_freqanalysis() using "multi-taper method"
% 5)   ft_connectivityanalysis() using 'coh' for coherence analysis
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
% See also ft_connectivityanalysis ft_freqanalysis

if nargin==0, help(mfilename('fullpath')); return; end


%% Input parsing

% Redefine trial
trial_length = ft_getopt(cfg, 'trial_length',   60 ); % seconds // does not effect 'dpss' result, but is mandatory for computation performances

% TFA to prepare coherence analysis
foilim       = ft_getopt(cfg,       'foilim', [2 8]); % [fmin fmax] (Hz) frequency of interest // [2 8] is a bit larger than [4 6] for tremors, useful for quality check
taper        = ft_getopt(cfg,        'taper','dpss'); % 'dpss' or 'hanning'
tapsmofrq    = ft_getopt(cfg,    'tapsmofrq',  0.05); % (Hz) // spectral smoothing, useful only for 'dpss'


%% Get EMG/ACC prepared data

data_emg_acc = farm.tfa.prepare_emg_acc( data, cfg );


%% Split the whole timeseries into sub-segments

cfg_redef = [];
cfg_redef.length  = trial_length; % seconds // size does not matter, lol, for 'dpss' taper
cfg_redef.overlap = 0;

data_TFA_redef = ft_redefinetrial( cfg_redef, data_emg_acc);


%% Step 1/2 - frequency analysis
% The coherence analysis will be performed on the fourier coefficents

cfg_TFA = [];
cfg_TFA.method    = 'mtmfft';     % analyses an entire spectrum for the entire data length, implements multitaper frequency transformation.
cfg_TFA.output    = 'fourier';    % complex Fourier spectra
cfg_TFA.pad       = 'maxperlen';  % (default)
cfg_TFA.foilim    = foilim;       % Frequency Of Interest
cfg_TFA.taper     = taper;        % taper for the FFT
cfg_TFA.tapsmofrq = tapsmofrq;    % amount of spectral smoothing through multi-tapering
TFA = ft_freqanalysis(cfg_TFA, data_TFA_redef);


%% Step 2/2 - coherence analysis

cfg_coh = [];
cfg_coh.method = 'coh';
coh = ft_connectivityanalysis(cfg_coh, TFA);


end % function
