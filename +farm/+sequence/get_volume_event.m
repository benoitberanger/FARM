function volume_event = get_volume_event( data )
% GET_VOLUME_EVENT will fetch volume events, according to data.volume_marker_name
%
% SYNTAX
%       volume_event = FARM.SEQUENCE.GET_VOLUME_EVENT( data )
%
% INPUTS
%       - data : see <a href="matlab: help farm_check_data">farm_check_data</a>
%

if nargin==0, help(mfilename('fullpath')); return; end


%% Main

volume_event = ft_filter_event( data.cfg.event, 'value', data.volume_marker_name );


end % function
