function select_channel( self, channel_description )
% SELECT_CHANNEL will save which channels will be used for the next processing steps
%
% SYNTAX
%         data.workflow.SELECT_CHANNEL()
%         data.workflow.SELECT_CHANNEL( channel_description )
%
% NOTES
%       if "channel_description" is empty or not provided, ALL channels are selected
%
% EXAMPLE
%       channel_description = [1 2   4 5]   % use a vector
%       channel_description = 'FCR'         % use a char as regex
%       channel_description = {'FCR','ECR'} % use a cellstr that will be converted to regex with farm.cellstr2regex
%
%
% See also farm.get_channel farm.cellstr2regex


if ~exist('channel_description', 'var')
    channel_description = self.data.channel_description;
end


%% Get channel name & number

[ channel_idx, channel_name ] = self.get_channel( channel_description );


%% Save channel info

self.selected_channels_idx  = channel_idx;
self.selected_channels_name = channel_name;


end % function
