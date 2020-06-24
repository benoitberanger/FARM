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


%% Prepare data

[ timeseries, channel_idx, channel_name, stage ] = farm_get_timeseries( data, channel_description, processing_stage, filter, order);


%% Plot

f = figure('Name',data.cfg.datafile,'NumberTitle','off');
tg = uitabgroup(f);

for chan = 1 : length(channel_name)
    fig_name = sprintf('%s @ channel %d / %s', stage,channel_idx(chan), channel_name{chan});
    t = uitab(tg,'Title',fig_name);
    ax(chan) = axes(t); %#ok<AGROW,LAXES>
    plot( ax(chan), (0:size(timeseries,2)-1)/data.fsample , timeseries(chan,:) )
    xlabel('time (s)')
    ylabel('Signal')
    
end % chan

linkaxes(ax,'xy')


end % function
