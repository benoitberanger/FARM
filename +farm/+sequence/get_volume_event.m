function volume_event = get_volume_event( data )

volume_event = ft_filter_event( data.cfg.event, 'value', data.volume_marker_name );

end % function
