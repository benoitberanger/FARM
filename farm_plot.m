function farm_plot( data )

field_name = fieldnames( data );

clean_idx = find(~cellfun(@isempty, strfind(field_name,'_clean'))); %#ok<STRCLFH>

if ~isempty(clean_idx)
    data.trial{1} = data.(field_name{clean_idx(end)});
end
ft_databrowser(data.cfg, data);

end
