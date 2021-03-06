function correlation = correlation( vector , matrix )
% GET_VOLUME_EVENT will fetch volume events, according to data.volume_marker_name
%
% SYNTAX
%       correlation = FARM.CORRELATION( vector , matrix )
%
% INPUTS
%       - vector      : vector (1 x n)
%       - matrix      : matrix (m x n)
%
% OUTPUTS
%       - correlation : vector (1 x n)
%
% NOTES
%       - n           : samples
%       - m           : variables
%

if nargin==0, help(mfilename('fullpath')); return; end


%% correlation(x,y) = covariance(x,y) / (var(x) * var(y))

% I choose to restrict this correlation computations in terms of input.
% This is not intended for general purpose, but for FARM specific usage.

x        = vector;
x_demean = x - mean(x,2); % remove mean
var_x    = sqrt(sum( x_demean.^2 ,2));

y        = matrix;
y_demean = y - mean(y,2); % remove mean
var_y    = sqrt(sum( y_demean.^2 ,2));

% We could do the computation using a loop, but this implementation without loop
% is much faster due to MATLAB nice parallisation for built-in functions.
%
% benchmark :
% >> x=rand(1,10000); y=rand(10000,10000); tic, correlation = farm.correlation( x , y ); toc
% Elapsed time is 0.418498 seconds.

correlation = sum( y_demean .* x_demean ,2) ./ (var_x .* var_y );

% Note : here the swap between x & y, and the transpose (') do NOT change the "result",
% and are only here for matrix dimensions agreements.


end % function
