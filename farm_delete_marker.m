function event = farm_delete_marker( event, marker_name )

marker_index = strcmp({event.value}, marker_name);
event(marker_index) = [];

end % function
