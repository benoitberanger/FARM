function channel = filter(channel, fsample, filter, order)
% FILTER uses ft_preproc_*filter
%
% SYNTAX
%       channel = FARM.FILTER(channel, fsample, filter, order)
%
% INPUTS
%       - channel : follow fieldtrip matrix orientation (Channel x Sample),
%                   each line is a channel, and the columns are the samples
%       - filter  :
%                   filter = -30      =>  low-pass filter @ 30       Hz
%                   filter = +100     => high-pass filter @ 100      Hz
%                   filter = +[ 1 12] => band-pass filter @ [ 1  12] Hz
%                   filter = -[59 61] => band-stop filter @ [59  61] Hz
%
%       - order   : order can be [] or an integer
%                   if left empty, the default filter order from ft_preproc_xxxxxfilter will be used.
%                   default is order=6
%

if nargin==0, help(mfilename('fullpath')); return; end


%% Input parsing

if ~exist('order','var')
    order = [];
end


%% Filter

switch length(filter)
    case 1
        if filter > 0                                                              % filter = +100     => high-pass filter @ 100    Hz
            channel = ft_preproc_highpassfilter( channel, fsample, +filter, order );
        elseif filter < 0                                                          % filter = -30      =>  low-pass filter @  30    Hz
            channel = ft_preproc_lowpassfilter ( channel, fsample, -filter, order );
        end
    case 2
        if all(filter > 0)                                                         % filter = +[ 1 12] => band-pass filter @ [ 1 12] Hz
            channel = ft_preproc_bandpassfilter( channel, fsample, +filter, order );
        elseif all(filter < 0)                                                     % filter = -[59 61] => band-stop filter @ [59 61] Hz
            channel = ft_preproc_bandstopfilter( channel, fsample, -filter, order );
        end
    case 0
        % pass, no filter applied
    otherwise
        error('Unrecognized filter. See help %s', mfilename)
end


end % function
