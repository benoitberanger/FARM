function [ signal_out, time_out ] = resample( signal_in, time_in, fsample, factor )
% RESAMPLE will upsample/downsample 'signal_in' by 'factor'
%
% SYNTAX
%       [ signal_out, time_out ] = FARM.RESAMPLE( signal_in, time_in, fsample, factor )
% INPUTS
%       - signal_in : vector (nChan x nSamples)
%       - time_in   : vector (nChan x nSamples)
%       - fsample   : sampling frequency, in Hertz (Hz)
%       - factor    : interpolation factor, positive number
%

if nargin==0, help(mfilename('fullpath')); return; end


%% Main

time_out = time_in(1) : 1/(fsample*factor) : time_in(end);

% Upsample, using matlab builtin function 'interp1'. 'pchip' = shape-preserving piecewise cubic interpolation
% Note : ft_resampledata uses the same function 'interp1'
signal_out = interp1( time_in', signal_in', time_out', 'pchip' )';


end % function
