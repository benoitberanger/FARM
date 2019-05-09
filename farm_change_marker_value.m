function event = farm_change_marker_value( event, old_maker_value, new_maker_value )

for evt = 1 : length(event)
    if strcmp(event(evt).value, old_maker_value)
        event(evt).value = new_maker_value;
    end
end

end % function
