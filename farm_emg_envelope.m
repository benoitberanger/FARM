function env = farm_emg_envelope( timeseries, fsample, lpf )
% FARM_EMG_ENVELOPE will get the envelope of EMG, using abs() then lowpass filter @ 8 Hz
%
% SYNTAX
%       env = FARM_EMG_ENVELOPE( timeseries , lpf )
%
% INPUTS
%       - timeseries : see <a href="matlab: help farm_get_timeseries">farm_get_timeseries</a>
%       - fsample    : sampling frequency, in Hertz (Hz)
%       - lpf        : lowpass filter => usually, 4 or 8 Hz to get enveloppe of EMG
%

if nargin==0, help(mfilename('fullpath')); return; end


%% Check

narginchk(2,3)

if ~exist('lpf','var')
    lpf = 8;
end


%% Main

env = farm.filter( abs(timeseries), fsample, -lpf );


end % function
