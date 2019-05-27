function [ time_out, signal_out ] = farm_resample( time_in, signal_in, fsample, factor )
% FARM_RESAMPLE will upsample/downsample 'signal_in' by 'factor'

time_out = time_in(1) : 1/(fsample*factor) : time_in(end);

% Upsample, using matlab builtin function 'interp1'. 'pchip' = shape-preserving piecewise cubic interpolation
% Note : ft_resampledata uses the same function 'interp1'
signal_out = interp1( time_in, signal_in, time_out, 'pchip' );

end % function
