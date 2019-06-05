function nVol = get_nVol( data )

volume_event = farm.sequence.get_volume_event( data );

if isfield(data.sequence,'nVol') && ~isempty(data.sequence.nVol)
    nVol = data.sequence.nVol;
else
    nVol = length(volume_event);
end

end % function
