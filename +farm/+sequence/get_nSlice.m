function nSlice = get_nSlice( data )

if isfield(data.sequence,'MB')
    nSlice = data.sequence.nSlice / data.sequence.MB;
else
    nSlice = data.sequence.nSlice;
end

end % function
