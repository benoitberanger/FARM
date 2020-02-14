function [ datapoints, channel_idx, channel_name, stage ] = get_datapoints( data, channel_description, processing_stage )
% GET_DATAPOINTS will fetch datapoints according the channel_description and processing_stage
%
% SYNTAX
%       [ datapoints, channel_idx, channel_name, stage ] = FARM.PLOT.GET_DATAPOINTS( data, channel_description, processing_stage )
%
% INPUTS
%       - data                : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - channel_description : <double> or 'regex' or {'regex1', 'regex12', ...}
%       - processing_stage    : 'regex'
%
% See also farm.cellstr2regex

if nargin==0, help(mfilename('fullpath')); return; end


%% Input parsing

if ~exist('processing_stage','var') || isempty(processing_stage)
    processing_stage = '';
end

if ~exist('channel_description','var') || isempty(channel_description)
    data = farm.detect_channel_with_greater_artifact( data );
    channel_description = data.target_channel;
end


%% Get channel name & number

[ channel_idx, channel_name ] = farm.get_channel( data, channel_description );


%% processing_stage

% Fetch all *_clean fields name
field_name = fieldnames( data );

if isempty(processing_stage)
    
    clean_idx  = find(~cellfun(@isempty, strfind(field_name,'_clean')), 1, 'last'); %#ok<STRCLFH>
    
    % Use the last *_clean field / or raw
    if ~isempty(clean_idx)
        stage      = field_name{clean_idx};
        datapoints = data.(stage)(channel_idx,:);
    else
        stage      = 'raw';
        datapoints = data.trial{1}(channel_idx,:);
    end
    
else
    
    if strcmpi(processing_stage,'raw')
        stage      = 'raw';
        datapoints = data.trial{1}(channel_idx,:);
    else
        stage_idx  = find(~cellfun(@isempty, strfind(field_name,processing_stage)), 1, 'last'); %#ok<STRCLFH>
        stage      = field_name{stage_idx};
        datapoints = data.(stage)(channel_idx,:);
    end
    
end


end % function
