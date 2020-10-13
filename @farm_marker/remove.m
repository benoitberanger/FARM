function remove( self, marker_name )
% REMOVE will remove in event all event.value==marker_name
%
% SYNTAX
%       data.marker.REMOVE( marker_name )
%
% INPUTS
%       - marker_name : event.value = number or string
%


%% Main

event = self.data.ftdata.cfg.event;

marker_index = strcmp({event.value}, marker_name);
event(marker_index) = [];

self.data.ftdata.cfg.event = event;


end % function
