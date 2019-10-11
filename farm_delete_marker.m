function event = farm_delete_marker( event, marker_name )
% FARM_DELETE_MARKER will remove in event all event.value==marker_name
%
% SYNTAX
%       event = FARM_DELETE_MARKER( event, marker_name )
%
% INPUTS
%       - event       : see <a href="matlab: help ft_read_event">ft_read_event</a>
%       - marker_name : event.value = number or string
%

if nargin==0, help(mfilename('fullpath')); return; end


%% Main

marker_index = strcmp({event.value}, marker_name);
event(marker_index) = [];


end % function
