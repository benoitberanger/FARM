function farm_plot( data, filter, order )
% FARM_PLOT will plot the data inside the volume markers
% The volume markers will be 'data.volume_marker_name'
% The channel will be detected by farm_detect_channel_with_greater_artifact
%
% Syntax : FARM_PLOT( data, filter )
%
% See also farm_filter

if nargin==0, help(mfilename); return; end

if nargin < 3
    order = [];
end


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
    channel = farm_filter(channel, data.fsample, filter, order);
end


volume_event = ft_filter_event( data.cfg.event, 'value', data.volume_marker_name );
if isfield(data.sequence,'nVol') && ~isempty(data.sequence.nVol)
    volume_event = volume_event(1:data.sequence.nVol);
end
channel      = channel(volume_event(1).sample : volume_event(end).sample);


%% Plot

figure('Name',sprintf('Plot @ channel %d',data.target_channel),'NumberTitle','off');
plot( (0:length(channel)-1)/data.fsample , channel )
xlabel('time (s)')
ylabel('Signal')


end % function
