function farm_carpet_plot( data, filter )
% FARM_CARPET_PLOT will plot the volume-segments of a channel
% The volume markers will be 'data.volume_marker_name'
% The channel will be detected by farm_detect_channel_with_greater_artifact
%
% Syntax : FARM_CARPET_PLOT( data, filter )
%
% See also farm_filter

if nargin==0, help(mfilename); return; end


%% Checks

farm_check_data( data )

data = farm_detect_channel_with_greater_artifact( data );


%% Fetch useful data

channel = data.trial{1}(data.target_channel,:);

% Filter
if nargin > 1
    channel = farm_filter(channel, data.fsample, filter);
end

volume_event = ft_filter_event( data.cfg.event, 'value', data.volume_marker_name );


%% Prepare the carpet

volume_segement = zeros(length(volume_event), data.sequence.TR * data.fsample);

for iVol = 1 : length(volume_event)
    volume_segement( iVol, : ) = channel( volume_event(iVol).sample : volume_event(iVol).sample + data.sequence.TR * data.fsample -1 );
end


%% Plot

figure
image(volume_segement,'CDataMapping','scaled')
colormap(gray(256))
colorbar


end % function
