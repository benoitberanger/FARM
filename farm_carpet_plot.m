function farm_carpet_plot( data, channel_description, processing_stage, filter, order )
% FARM_CARPET_PLOT will plot the volume-segments of a channel
% The volume markers will be 'data.volume_marker_name'
%
% Syntax : FARM_CARPET_PLOT( data, channel_description, processing_stage, filter, order )
%
% Inputs :
% - data : classic data for most
% - channel_description : can be channel index [1 2 ...] or a regex for data.label
% - processing_stage : regex for field in data, exept for 'raw' which means data.trial{1}
% - filter & order : see < help farm.filter > 
%
% See also farm.filter

if nargin==0, help(mfilename); return; end


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


%% Prepare the carpet

volume_segment = zeros(length(volume_event), data.sequence.TR * data.fsample);

for iVol = 1 : length(volume_event)
    volume_segment( iVol, : ) = datapoints( volume_event(iVol).sample : volume_event(iVol).sample + data.sequence.TR * data.fsample -1 );
end


%% Plot

fig_name = sprintf('Carpet plot ''%s'' @ channel %d / %s', stage,channel_idx, channel_name);
figure('Name',fig_name,'NumberTitle','off');
image(volume_segment,'CDataMapping','scaled')
colormap(gray(256))
colorbar
xlabel('samples in TR')
ylabel('TR index')


end % function
