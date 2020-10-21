function [ channel_idx, channel_name ] = get_channel( self, channel_description )
% GET_CHANNEL will interpret "channel_description" to fetch channel index and name
%
% SYNTAX
%       [ channel_idx, channel_name ] = data.workflow.GET_CHANNEL( channel_description )
%
% INPUTS
%       - channel_description : <double> or 'regex' or {'regex1', 'regex12', ...}
%
% See also farm.cellstr2regex


%% Input parsing

if ~exist('channel_description','var') || isempty(channel_description)
    channel_description = '.*';
end


%% Interpret

switch class(channel_description)
    case 'double'
        channel_idx = channel_description;
    case 'char'
        res = regexp( self.data.ftdata.label, channel_description );
        res = ~cellfun(@isempty,res);
        channel_idx = find(res);
    case 'cell'
        assert( iscellstr(channel_description), 'when "channel_description" is a cell, it must be cellstr')
        res = regexp( self.data.ftdata.label, farm.cellstr2regex(channel_description) );
        res = ~cellfun(@isempty,res);
        channel_idx = find(res);
    otherwise
        error('[%s]: unrecognized nature of "channel_description"', mfilename)
end

channel_name = self.data.ftdata.label(channel_idx);

if isempty(channel_idx)
    warning('[%s]: no channel found',mfilename)
end


end % function
