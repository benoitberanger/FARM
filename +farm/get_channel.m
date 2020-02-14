function [ channel_idx, channel_name ] = get_channel( data, channel_description )
% GET_CHANNEL will interpret "channel_description" to fetch channel index and name
%
% SYNTAX
%       [ channel_idx, channel_name ] = GET_CHANNEL( data, channel_description )
%
% INPUTS
%       - data                : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - channel_description : <double> or 'regex' or {'regex1', 'regex12', ...}
%
% See also farm.cellstr2regex

if nargin==0, help(mfilename('fullpath')); return; end


%% Input parsing

if ~exist('channel_description','var') || isempty(channel_description)
    data = farm.detect_channel_with_greater_artifact( data );
    channel_description = data.target_channel;
end


%% Interpret

switch class(channel_description)
    case 'double'
        channel_idx = channel_description;
    case 'char'
        res = regexp( data.label, channel_description );
        res = ~cellfun(@isempty,res);
        channel_idx = find(res);
    case 'cell'
        assert( iscellstr(channel_description), 'when "channel_description" is a cell, it must be cellstr')
        res = regexp( data.label, farm.cellstr2regex(channel_description) );
        res = ~cellfun(@isempty,res);
        channel_idx = find(res);
    otherwise
        error('[%s]: unrecognized nature of "channel_description"', mfilename)
end

channel_name = data.label(channel_idx);


end % function
