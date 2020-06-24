function farm_plot_FFT( data, channel_description, processing_stage, filter, order )
% FARM_PLOT_FFT will plot
% (1) the data inside the volume markers
% (2) it's FFT
%
% SYNTAX
%       FARM_PLOT_FFT( data, channel_description, processing_stage, filter, order )
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
    axes(t); %#ok<LAXES>
    
    if rem(size(timeseries,2),2)
        timeseries(:,end) = []; % to avoid a warning
    end
    
    L = size(timeseries,2);
    
    ax_time(chan) = subplot(2,1,1); %#ok<AGROW>
    plot(ax_time(chan), (0:(L-1))/data.fsample , timeseries(chan,:) )
    xlabel('time (s)')
    ylabel('Signal')
    
    Y = fft(timeseries(chan,:));
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = data.fsample*(0:(L/2))/L;
    
    ax_freq(chan) = subplot(2,1,2); %#ok<AGROW>
    plot(ax_freq(chan), f,P1)
    
    xlabel('Frequency (Hz)')
    ylabel('Power')
    
end % chan

linkaxes(ax_time,'xy')
linkaxes(ax_freq,'xy')


end % function
