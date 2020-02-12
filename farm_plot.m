function farm_plot( data, channel_description, processing_stage, filter, order )
% FARM_PLOT will plot the data inside the volume markers
%
% SYNTAX
%       FARM_PLOT( data, channel_description, processing_stage, filter, order )
%
% INPUTS
%       - data                : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - channel_description : can be channel index [1 2 ...] or a regex for data.label
%       - processing_stage    : regex for field in data, exept for 'raw' which means data.trial{1}
%       - filter & order      : see <a href="matlab: help farm.filter">farm.filter</a>
%
% NOTES
% The volume markers will be 'data.volume_marker_name'
%

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

data = farm.detect_channel_with_greater_artifact( data );


%% Prepare data

[ datapoints, channel_idx, channel_name, stage ] = farm.plot.get_datapoints( data, channel_description, processing_stage );

% Filter
if nargin > 1
    datapoints = farm.filter(datapoints, data.fsample, filter, order);
end

volume_event = farm.sequence.get_volume_event( data );
nVol         = farm.sequence.get_nVol        ( data );
volume_event = volume_event(1:nVol);
datapoints = datapoints( : , volume_event(1).sample : volume_event(end).sample);


%% Plot

for chan = 1 : length(channel_name)
    
    set(0,'DefaultFigureWindowStyle','docked')
    fig_name = sprintf('Plot ''%s'' @ channel %d / %s', stage,channel_idx(chan), channel_name{chan});
    figure('Name',fig_name,'NumberTitle','off');
    plot( (0:size(datapoints,2)-1)/data.fsample , datapoints(chan,:) )
    xlabel('time (s)')
    ylabel('Signal')
    
end % chan


end % function
