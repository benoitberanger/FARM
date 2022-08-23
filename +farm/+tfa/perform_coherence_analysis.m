function coh = perform_coherence_analysis( data, cfg )
% PERFORM_COHERENCE_ANALYSIS use ft_freqanalysis() then ft_connectivityanalysis()
%
% SYNTAX
%       coh = farm.tfa.PERFORM_COHERENCE_ANALYSIS( data, cfg )
%
% INPUTS
%       - data : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - cfg  : check in the code of the function
%
% NOTES
%
%
% See also ft_connectivityanalysis ft_freqanalysis ft_redefinetrial

if nargin==0, help(mfilename('fullpath')); return; end


%% Input parsing

% Redefine trial
trial_length = ft_getopt(cfg, 'trial_length',   60 ); % seconds // does not effect 'dpss' result, but is mandatory for computation performances

% TFA to prepare coherence analysis
foilim       = ft_getopt(cfg,          'foi', [2 8]); % [fmin fmax] (Hz) frequency of interest // [2 8] is a bit larger than [4 6] for tremors, useful for quality check
taper        = ft_getopt(cfg,        'taper','dpss'); % 'dpss' or 'hanning'
tapsmofrq    = ft_getopt(cfg,    'tapsmofrq',  0.05); % (Hz) // spectral smoothing, useful only for 'dpss'


%% Split the whole timeseries into sub-segments

cfg_redef = [];
cfg_redef.length  = trial_length; % seconds // size does not matter, lol, for 'dpss' taper
cfg_redef.overlap = 0;

data_TFA_redef = ft_redefinetrial( cfg_redef, data);


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
