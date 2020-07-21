function TFA = postprocessing( TFA, cfg )
% POSTPROCESSING
% TFA post-processing : for each channels & averaged channels
%   a) power average across frequency
%   b) power average across time
%   c) power @ peak frequency
%
% SYNTAX
%       TFA = farm.tfa.POSTPROCESSING( data, cfg )
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

% Frequency range selection
rangeF = ft_getopt(cfg, 'rangeF', 1.0); % (Hz) range of frequency average around the peak frequency


%% Post-processing
% Important note : here, 'avg' means 'average across channels'

powspctrm = TFA.powspctrm;           % copy
powspctrm(isnan(TFA.powspctrm)) = 0; % for convinience

dF = mean(diff(TFA.freq));   % Hz
dN = round(rangeF / dF / 2);  % We take rangeF (Hz) around the peak frequency

for chan = 1 : length(TFA.label)
    
    TFA.power_Tmean(chan,:)  = mean( powspctrm(chan,:,:), 3);                    % (nChan x nFreq   )
    TFA.power_Fmean(chan,:)  = mean( powspctrm(chan,:,:), 2);                    % (nChan x nSample )
    [~,I] = max(TFA.power_Tmean(chan,:));
    TFA.peakfreq (chan)    = TFA.freq(I);                                        % (nChan x 1       )
    TFA.peakpower(chan,:)  = mean( squeeze( powspctrm(chan, I-dN:I+dN,:) ) , 1); % (nChan x nSamples)
    
end % chan

TFA.  powspctrm_avg = squeeze( mean( powspctrm      , 1 ) );
TFA.power_Tmean_avg =          mean( TFA.power_Tmean, 1 )  ;
TFA.power_Fmean_avg =          mean( TFA.power_Fmean, 1 )  ;
[~,I]               = max(TFA.power_Tmean_avg);
TFA.peakfreq_avg    = TFA.freq(I);
TFA.peakpower_avg   = mean(TFA.powspctrm_avg(I-dN:I+dN,:) , 1 );


end % function
