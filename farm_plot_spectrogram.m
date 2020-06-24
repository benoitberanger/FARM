function farm_plot_spectrogram( data, channel_description, processing_stage, filter, order )
% FARM_PLOT_SPECTROGRAM will plot time-frequency graph
%
% SYNTAX
%       FARM_PLOT_SPECTROGRAM( data, channel_description, processing_stage, filter, order )
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

% Prepare some time-frequency stuff
nrPoints   = size(timeseries,2);
nrSections = floor(nrPoints/1e3); % 1000 points window
nrOverlap  = floor(nrSections/2); % 50% overlap
nfft       = max(256,2^nextpow2(nrSections)); % ?

f = figure('Name',data.cfg.datafile,'NumberTitle','off');
tg = uitabgroup(f);

for chan = 1 : length(channel_name)
    
    fig_name = sprintf('%s @ channel %d / %s', stage,channel_idx(chan), channel_name{chan});
    t = uitab(tg,'Title',fig_name);
    axes(t); %#ok<LAXES>
    
    ax_freq(chan) = subplot(4,1,1:3); %#ok<AGROW>
    [S,F,T,P,Fc,Tc] = spectrogram(timeseries(chan,:),hann(nrSections),nrOverlap,nfft,data.fsample,'yaxis','MinThreshold',-3); % all power below -3dB is discarded
    [nTime,nFrequency] = size(S);
    time      = (0:nTime-1)/nTime*nrPoints/data.fsample;
    frequency = (0:nFrequency-1)/nFrequency*data.fsample/2;
    imagesc(time,frequency,10*log10(abs(P)));
    ylabel('Power dB/Hz')
    set(ax_freq(chan), 'YDir', 'normal')
    
    ax_time(chan) = subplot(4,1,4); %#ok<AGROW>
    plot(ax_time(chan), (0:size(timeseries,2)-1)/data.fsample , timeseries(chan,:) )
    xlabel('time (s)')
    ylabel('Signal')
    
end % chan

linkaxes(ax_freq,'xy'   )
axis    (ax_time,'tight')
linkaxes(ax_time,'xy'   )


end % function
