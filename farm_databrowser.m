function farm_databrowser( data, filter, order )
% FARM_DATABROWSER will use ft_databrowser on the most recent *_clean field
%
% SYNTAX
%       FARM_DATABROWSER( data, filter )
%
% INPUTS
%       - data : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - processing_stage : regex for field in data, exept for 'raw' which means data.trial{1}
%       - filter & order : see <a href="matlab:help farm.filter">farm.filter</a>
%
% See also ft_databrowser

if nargin==0, help(mfilename('fullpath')); return; end


%% Input parsing

if ~exist('filter','var')
    filter = [];
end

if ~exist('order','var')
    order = [];
end


%% Prepare data

% Fetch all *_clean fields name
field_name = fieldnames( data );
clean_idx  = find(~cellfun(@isempty, strfind(field_name,'_clean'))); %#ok<STRCLFH>

% Use the last *_clean field
if ~isempty(clean_idx)
    data.trial{1} = data.(field_name{clean_idx(end)});
end

% Filter
if ~isempty(filter)
    data.trial{1} = farm_filter(data.trial{1}, data.fsample, filter, order);
end


%% Browser

ft_databrowser(data.cfg, data);


end
