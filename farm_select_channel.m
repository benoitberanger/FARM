function data = farm_select_channel( data, channel_description )
% FARM_SELECT_CHANNEL will save which channels will be used for the next processing steps
%
% SYNTAX
%         data = FARM_SELECT_CHANNEL( data, channel_description )
%
% INPUTS
%       - data                : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - channel_description : can be channel index [1 2 ...] or a regex (char or cellstr) for data.label
%
% NOTES
%       if "channel_description" is empty or not provided, ALL channels are selected
%
% EXAMPLE
%       data = FARM_SELECT_CHANNEL( data, [1 2   4 5]   ) % use a vector
%       data = FARM_SELECT_CHANNEL( data, 'FCR'         ) % use a char as regex
%       data = FARM_SELECT_CHANNEL( data, {'FCR','ECR'} ) % use a cellstr that will be converted to regex with farm.cellstr2regex
%
%
% See also farm.cellstr2regex


if nargin==0, help(mfilename('fullpath')); return; end


%% Check input arguments

narginchk(1,2)

farm_check_data( data )

if ~exist('channel_description', 'var')
    channel_description = [];
end


%% Get channel name & number

[ channel_idx, channel_name ] = farm.get_channel( data, channel_description );


%% Save channel info

data.selected_channels_idx  = channel_idx;
data.selected_channels_name = channel_name;


end % function
