function event = farm_offset_marker(event, value, offset)
% FARM_OFFSET_MARKER will offcet in event all event.value==value by offset
%
% SYNTAX
%       event = FARM_OFFSET_MARKER(event, value, offset)
%
% INPUTS
%       - event  : see <a href="matlab: help ft_read_event">ft_read_event</a>
%       - value  : event.value = number or string
%       - offset : number of samples to shift, integer, can be positive or negative
%

if nargin==0, help(mfilename('fullpath')); return; end


%% Main

idx = find(strcmp({event.value},value));

for evt = 1 : length(idx)
    event(idx(evt)).sample = event(idx(evt)).sample + offset;
end


end % function
