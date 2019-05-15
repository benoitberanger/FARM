function farm_carpet_plot( data, filter )
% FARM_CARPET_PLOT will plot the volume-segments of a channel
% The volume markers will be 'data.volume_marker_name'
% The channel will be detected by farm_detect_channel_with_greater_artifact
%
% Syntax : FARM_CARPET_PLOT( data, filter )
%
% filter = -30      =>  low-pass filter @  30    Hz
% filter = +100     => high-pass filter @ 100    Hz
% filter = +[ 1 12] => band-pass filter @ [ 1 12] Hz
% filter = -[59 61] => band-stop filter @ [59 61] Hz
%

if nargin==0, help(mfilename); return; end


%% Checks

farm_check_data( data )

data = farm_detect_channel_with_greater_artifact( data );


%% Fetch useful data

channel = data.trial{1}(data.target_channel,:);

if nargin > 1
    
    switch length(filter)
        case 1
            if filter > 0
                channel = ft_preproc_highpassfilter( channel, data.fsample, +filter );
            elseif filter < 0
                channel = ft_preproc_lowpassfilter ( channel, data.fsample, -filter );
            end
        case 2
            if all(filter > 0)
                channel = ft_preproc_bandpassfilter( channel, data.fsample, +filter );
            elseif all(filter < 0)
                channel = ft_preproc_bandstopfilter( channel, data.fsample, -filter );
            end
        otherwise
            error('')
    end
    
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
