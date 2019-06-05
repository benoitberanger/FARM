function [ datapoints, channel_idx, channel_name, stage ] = get_datapoints( data, channel_description, processing_stage )
% GET_DATAPOINTS
%
% Syntax : [ datapoints, channel_idx, channel_name, stage ] = GET_DATAPOINTS( data, channel_description, processing_stage )
%
% channel_description : <double> or 'regex'
% processing_stage    : 'regex'
%
%

%% Input parsing

if ~exist('processing_stage','var') || isempty(processing_stage)
    processing_stage = '';
end

if ~exist('channel_description','var') || isempty(channel_description)
    data = farm.detect_channel_with_greater_artifact( data );
    channel_description = data.target_channel;
end


%% channel_description

switch class(channel_description)
    case 'double'
        channel_idx = channel_description;
    case 'char'
        res = regexp( data.label, channel_description );
        res = ~cellfun(@isempty,res);
        channel_idx = find(res,1,'first');
end
channel_name = data.label{channel_idx};


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
        stage_idx = find(~cellfun(@isempty, strfind(field_name,processing_stage)), 1, 'last'); %#ok<STRCLFH>
        stage      = field_name{stage_idx};
        datapoints = data.(stage)(channel_idx,:);
    end
    
end


end % function
