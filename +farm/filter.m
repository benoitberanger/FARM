function channel = filter(channel, fsample, filter, order)
% FILTER uses ft_preproc_*filter
%
% 'channel' follow fieldtrip matrix orientation (Channel x Sample),
% each line is a channel, and the columns are the samples
%
% Syntax : channel = FILTER(channel, fsample, filter)
%
% filter = -30      =>  low-pass filter @ 30       Hz
% filter = +100     => high-pass filter @ 100      Hz
% filter = +[ 1 12] => band-pass filter @ [ 1  12] Hz
% filter = -[59 61] => band-stop filter @ [59  61] Hz
%

if nargin==0, help(mfilename); return; end

if nargin < 4
    order = [];
end


%% Main

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
