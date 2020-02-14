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

% Prepare some time-frequency stuff
nrPoints   = size(datapoints,2);
nrSections = floor(nrPoints/1e3); % 1000 points window
nrOverlap  = floor(nrSections/2); % 50% overlap
nfft       = max(256,2^nextpow2(nrSections)); % ?

f = figure('Name',mfilename,'NumberTitle','off');
tg = uitabgroup(f);

for chan = 1 : length(channel_name)
    
    fig_name = sprintf('%s @ channel %d / %s', stage,channel_idx(chan), channel_name{chan});
    t = uitab(tg,'Title',fig_name);
    axes(t); %#ok<LAXES>
    
    ax(1) = subplot(4,1,1:3);
    [S,F,T,P,Fc,Tc] = spectrogram(datapoints(chan,:),hann(nrSections),nrOverlap,nfft,data.fsample,'yaxis','MinThreshold',-3); % all power below -3dB is discarded
    [nTime,nFrequency] = size(S);
    time      = (0:nTime-1)/nTime*nrPoints/data.fsample;
    frequency = (0:nFrequency-1)/nFrequency*data.fsample/2;
    imagesc(time,frequency,10*log10(abs(P)));
    ylabel('Power dB/Hz')
    set(ax(1), 'YDir', 'normal')
    
    ax(2) = subplot(4,1,4);
    plot( (0:size(datapoints,2)-1)/data.fsample , datapoints(chan,:) )
    xlabel('time (s)')
    ylabel('Signal')
    
    linkaxes(ax,'x');
    
end % chan


end % function
