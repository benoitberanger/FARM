function event = farm_remove_last_volume_event( event, volume_marker_name )
% FARM_REMOVE_LAST_VOLUME_EVENT will delete the last volume marker.
% This is usefull in the case of manually stopped sequence.
% When the last volume is incomplete, a marker is still be present.
% The last unfinished volume will mess with denoising.
%
% SYNTAX
%       event = FARM_REMOVE_LAST_VOLUME_EVENT( event, volume_marker_name )
%
% INPUTS
%       - event : see <a href="matlab: help ft_read_event">ft_read_event</a>
%

if nargin==0, help(mfilename('fullpath')); return; end


%% Main

is_volume                = strcmp({event.value}, volume_marker_name);
last_volume_index        = find(is_volume,1,'last');
event(last_volume_index) = [];


end % function
