function farm_plotFFT( data, filter )
% FARM_PLOTFFT will plot (1) the data inside the volume markers (2) it's FFT
% The volume markers will be 'data.volume_marker_name'
% The channel will be detected by farm_detect_channel_with_greater_artifact
%
% Syntax : FARM_PLOTFFT( data, filter )
%
% See also farm_filter

if nargin==0, help(mfilename); return; end


%% Checks

farm_check_data( data )

data = farm_detect_channel_with_greater_artifact( data );


%% Prepare data

% Fetch all *_clean fields name
field_name = fieldnames( data );
clean_idx  = find(~cellfun(@isempty, strfind(field_name,'_clean'))); %#ok<STRCLFH>

% Use the last *_clean field
if ~isempty(clean_idx)
    channel = data.(field_name{clean_idx(end)})(data.target_channel,:);
else
    channel = data.trial{1}(data.target_channel,:);
end

% Filter
if nargin > 1
    channel = farm_filter(channel, data.fsample, filter);
end


volume_event = ft_filter_event( data.cfg.event, 'value', data.volume_marker_name );
channel      = channel(volume_event(1).sample : volume_event(end).sample);


%% Plot

figure('Name',sprintf('Plot @ channel %d',data.target_channel),'NumberTitle','off');

if rem(length(channel),2)
    channel(end) = []; % to avoid a warning
end

L = length(channel);

subplot(2,1,1)
plot( (0:(L-1))/data.fsample , channel )
xlabel('time (s)')
ylabel('Signal')

Y = fft(channel);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = data.fsample*(0:(L/2))/L;

subplot(2,1,2)
plot(f,P1)

xlabel('Frequency (Hz)')
ylabel('|Y(channel)|')


end % function
