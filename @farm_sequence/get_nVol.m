function nVol = get_nVol( data )
% GET_NVOL will fetch the number of volumes, according to data.sequence
%
% SYNTAX
%        nVol = FARM.SEQUENCE.GET_NVOL( data )
%
% INPUTS
%       - data : see <a href="matlab: help farm_check_data">farm_check_data</a>
%

if nargin==0, help(mfilename('fullpath')); return; end


%% Main

volume_event = farm.sequence.get_volume_event( data );

if isfield(data.sequence,'nVol') && ~isempty(data.sequence.nVol)
    nVol = data.sequence.nVol;
else
    nVol = length(volume_event);
end

end % function
