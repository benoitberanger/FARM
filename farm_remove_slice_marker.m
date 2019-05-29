function data = farm_remove_slice_marker( data )
% FARM_REMOVE_SLICE_MARKER

slice_marker_index = strcmp({data.cfg.event.value},'s');

data.cfg.event(slice_marker_index) = [];

end % function
