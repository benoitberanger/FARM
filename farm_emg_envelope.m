function env = farm_emg_envelope( timeseries, fsample, option )
% FARM_EMG_ENVELOPE will get the envelope of EMG :
% - using ft_preproc_hilbert(timeseries, 'abs') <--- (default)
% - using abs() then lowpass filter
%
% SYNTAX
%       env = FARM_EMG_ENVELOPE( timeseries         )
%       env = FARM_EMG_ENVELOPE( timeseries, option )
%
% EXEMPLE
%       env = FARM_EMG_ENVELOPE( timeseries            )  % use default option
%       env = FARM_EMG_ENVELOPE( timeseries, 'hilbert' )  % default option
%       env = FARM_EMG_ENVELOPE( timeseries,         8 )  % option value is the LPF frequency
%
% INPUTS
%       - timeseries : see <a href="matlab: help farm_get_timeseries">farm_get_timeseries</a>
%       - fsample    : sampling frequency, in Hertz (Hz)
%       - option     : cant be : - 'hilbert'
%                                - integer, LPF frequency, such as 8
%

if nargin==0, help(mfilename('fullpath')); return; end


%% Check

narginchk(2,3)

if ~exist('lpf','var')
    option = 'hilbert';
end


%% Main

switch class(option)
    case 'char'
        env = ft_preproc_hilbert(timeseries, 'abs');
    case 'double'
        env = farm.filter( abs(timeseries), fsample, -option );
    otherwise
        error('[%s]: inkonwn option', mfilename)
end


end % function
