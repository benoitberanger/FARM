function data = farm_remove_slice_marker( data )
% FARM_REMOVE_SLICE_MARKER

data.cfg.event = farm_delete_marker( data.cfg.event, 's' );

end % function
