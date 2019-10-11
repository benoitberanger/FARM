function event = farm_change_marker_value( event, old_maker_value, new_maker_value )
% FARM_CHANGE_MARKER_VALUE will replace in 'event' the 'old_maker_value' with the 'new_maker_value'
%
% SYNTAX
%       event = FARM_CHANGE_MARKER_VALUE( event, old_maker_value, new_maker_value )
%
% INPUTS
%       - event           : see <a href="matlab: help ft_read_event">ft_read_event</a>
%       - old_maker_value : event.value = number or string
%       - new_maker_value : event.value = number or string
%

if nargin==0, help(mfilename('fullpath')); return; end


%% Main

for evt = 1 : length(event)
    if strcmp(event(evt).value, old_maker_value)
        event(evt).value = new_maker_value;
    end
end


end % function
