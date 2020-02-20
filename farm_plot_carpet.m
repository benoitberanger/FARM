function farm_plot_carpet( data, channel_description, processing_stage, filter, order )
% FARM_PLOT_CARPET will plot the data in 2D such as each line is one TR, and columns are samples.
% This is a nice way to see the periodicty of the MRI artifact, and to check the effect of the denoising.
%
% SYNTAX
%       FARM_PLOT_CARPET( data, channel_description, processing_stage, filter, order )
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


%% Prepare data

[ datapoints, channel_idx, channel_name, stage ] = farm.plot.get_datapoints( data, channel_description, processing_stage );

% Filter
if nargin > 1
    datapoints = farm.filter(datapoints, data.fsample, filter, order);
end

volume_event = farm.sequence.get_volume_event( data );
nVol         = farm.sequence.get_nVol        ( data );
volume_event = volume_event(1:nVol);
timeseries   = datapoints;


%% For each channel found

f = figure('Name',mfilename,'NumberTitle','off');
tg = uitabgroup(f);

for chan = 1 : length(channel_name)
    
    % Prepare the carpet
    volume_segment = zeros(length(volume_event), data.sequence.TR * data.fsample);
    for iVol = 1 : length(volume_event)
        volume_segment( iVol, : ) = timeseries( chan, volume_event(iVol).sample : volume_event(iVol).sample + data.sequence.TR * data.fsample -1 );
    end
    
    % Plot
    fig_name = sprintf('%s @ channel %d / %s', stage,channel_idx(chan), channel_name{chan});
    t = uitab(tg,'Title',fig_name);
    ax(chan) = axes(t); %#ok<AGROW,LAXES>
    image(ax(chan),volume_segment,'CDataMapping','scaled')
    colormap(gray(256))
    colorbar
    xlabel('samples in TR')
    ylabel('TR index')
    
end % chan

linkaxes(ax,'xy')


end % function
