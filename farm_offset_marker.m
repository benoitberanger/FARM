function event = farm_offset_marker(event, value, offset)

idx = find(strcmp({event.value},value));

for evt = 1 : length(idx)
    event(idx(evt)).sample = event(idx(evt)).sample + offset;
end

end % function
