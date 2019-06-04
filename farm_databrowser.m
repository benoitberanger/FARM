function farm_databrowser( data, filter )
% FARM_DATABROWSER will use ft_databrowser on the most recent *_clean field
%
% See also ft_databrowser farm_filter

if nargin==0, help(mfilename); return; end


%% Prepare data

% Fetch all *_clean fields name
field_name = fieldnames( data );
clean_idx  = find(~cellfun(@isempty, strfind(field_name,'_clean'))); %#ok<STRCLFH>

% Use the last *_clean field
if ~isempty(clean_idx)
    data.trial{1} = data.(field_name{clean_idx(end)});
end

% Filter
if nargin > 1
    data.trial{1} = farm_filter(data.trial{1}, data.fsample, filter);
end


%% Browser

ft_databrowser(data.cfg, data);


end
