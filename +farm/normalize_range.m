function out = normalize_range( in )
% FARM.NORMALIZE_RANGE will change range to [-1 ... +1] of a ( nChan x nSamples ) input

if nargin==0, help(mfilename('fullpath')); return; end


%% Main

out = in ./ max(abs(in),[],2);


end % function
