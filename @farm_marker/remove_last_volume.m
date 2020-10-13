function remove_last_volume( self )
% REMOVE_LAST_VOLUME will delete the last volume marker.
% This is usefull in the case of manually stopped sequence.
% When the last volume is incomplete, a marker is still be present.
% The last unfinished volume will mess with denoising.
%
% SYNTAX
%       data.marker.REMOVE_LAST_VOLUME()
%
% INPUTS
%


%% Main

event = self.data.ftdata.cfg.event;

is_volume                = strcmp({event.value}, self.volume_marker_name);
last_volume_index        = find(is_volume,1,'last');
event(last_volume_index) = [];

self.data.ftdata.cfg.event = event;


end % function
