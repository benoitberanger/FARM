function data = farm_detect_channel_with_greater_artifact( data )
% FARM_DETECT_CHANNEL_WITH_GREATER_ARTIFACT will detect which channel has the biggest artifact,
% and store the channel index for latter use.

if nargin==0, help(mfilename); return; end

if ~isfield( data, 'target_channel' )
    
    max_all_channels = max( abs(data.trial{1}), [], 2 );
    [ ~, target_channel ] = max(max_all_channels); % index of the channel we use to perform all computations related to sdur & dtime
    
    data.target_channel = target_channel; % save this channel index, we will use latter
    
end

end % function
