function farm_carpet_plot( data, filter, order )
% FARM_CARPET_PLOT will plot the volume-segments of a channel
% The volume markers will be 'data.volume_marker_name'
% The channel will be detected by farm_detect_channel_with_greater_artifact
%
% Syntax : FARM_CARPET_PLOT( data, filter )
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

%% Prepare the carpet

volume_segment = zeros(length(volume_event), data.sequence.TR * data.fsample);

for iVol = 1 : length(volume_event)
    volume_segment( iVol, : ) = channel( volume_event(iVol).sample : volume_event(iVol).sample + data.sequence.TR * data.fsample -1 );
end


%% Plot

figure('Name',sprintf('Carpet plot @ channel %d',data.target_channel),'NumberTitle','off');
image(volume_segment,'CDataMapping','scaled')
colormap(gray(256))
colorbar
xlabel('samples in TR')
ylabel('TR index')


end % function
