function output = log_transform( input )
% LOG_TRANSFORM will apply log() function but with some pre-adjusments
% The adjusments transform the input so it has no negative value
%
% SYNTAX
%       output = farm.LOG_TRANSFORM( input )
%
% INPUT
%       - input is (1 x nSamples)
%

if nargin==0, help(mfilename('fullpath')); return; end


%%

output = input;

neg_val_idx = output < 0;
if any(neg_val_idx)
    output = output - min(output(neg_val_idx)); % shift the curve up, so there is no negative values
end
output = farm.normalize_range(output);       % normalize & avoid having a 0, which would give log(0)=-Inf
output = log(output);                        % log transform
output(output==-Inf) = min(output(output~=-Inf)); % remove -Inf
output = output - min(output);               % shift up
output = farm.normalize_range(output);       % normalize


end % function
