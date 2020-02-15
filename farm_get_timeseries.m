function [ timeseries, channel_idx, channel_name, stage ] = farm_get_timeseries( data, channel_description, processing_stage, filter, order)
% FARM_GET_TIMESERIES will fetch datapoints within the fMRI sequence, according the channel_description and processing_stage
%
% SYNTAX
%       [ timeseries, channel_idx, channel_name, stage ] = FARM_GET_TIMESERIES( data, channel_description, processing_stage, filter, order)
%
% INPUTS
%       - data                : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - channel_description : can be channel index [1 2 ...] or a regex for data.label
%       - processing_stage    : regex for field in data, exept for 'raw' which means data.trial{1}
%       - filter & order      : see <a href="matlab: help farm.filter">farm.filter</a>
%
% NOTES
%       The volume markers will be 'data.volume_marker_name'
%
%
% See also farm.cellstr2regex

if nargin==0, help(mfilename('fullpath')); return; end


%% Input parsing

if ~exist('channel_description','var')
    channel_description = [];
end

if ~exist('processing_stage','var')
    processing_stage = [];
end

if ~exist('filter','var')
    filter = [];
end

if ~exist('order','var')
    order = [];
end


%% Checks

farm_check_data( data )


%% Prepare data

[ datapoints, channel_idx, channel_name, stage ] = farm.plot.get_datapoints( data, channel_description, processing_stage );

% Filter
if nargin > 1
    datapoints = farm.filter(datapoints, data.fsample, filter, order);
end

volume_event = farm.sequence.get_volume_event( data );
nVol         = farm.sequence.get_nVol        ( data );
volume_event = volume_event(1:nVol);
timeseries   = datapoints( : , volume_event(1).sample : volume_event(end).sample);


end % function
