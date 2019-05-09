function event = farm_offset_marker(event, offset)

for evt = 1 : length(event)
    event(evt).sample = event(evt).sample + offset;
end

end % function
