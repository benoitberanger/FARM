function varargout = farm_plot_FFT( data, channel_description, processing_stage, filter, order )
% FARM_PLOT_FFT will plot
% (1) the data inside the volume markers
% (2) it's FFT
%
% SYNTAX
%              FARM_PLOT_FFT( data, channel_description, processing_stage, filter, order )
%       figH = FARM_PLOT_FFT( data, channel_description, processing_stage, filter, order )
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

figH = figure('Name',data.cfg.datafile,'NumberTitle','off');
figH.UserData = mfilename;

tg = uitabgroup(figH);

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
    freq = data.fsample*(0:(L/2))/L;
    
    ax_freq(chan) = subplot(2,1,2); %#ok<AGROW>
    plot(ax_freq(chan), freq,P1)
    
    xlabel('Frequency (Hz)')
    ylabel('Power')
    
end % chan

axis    (ax_time,'tight')
linkaxes(ax_time,'xy'   )
axis    (ax_freq,'tight')
linkaxes(ax_freq,'xy'   )

% Adapt view of the FFT when filter is lpf or bpf
switch length(filter)
    case 1
        if filter > 0
        elseif filter < 0
            ylim( ax_freq, [0                 -filter*1.5] )
        end
    case 2
        if all(filter > 0)
            xlim( ax_freq, [filter(1)*0.5   filter(2)*1.5] )
        elseif all(filter < 0)
        end
end


%% Output ?

if nargout
    varargout{1} = figH;
end


end % function
