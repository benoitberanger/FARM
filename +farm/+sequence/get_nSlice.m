function nSlice = get_nSlice( data )
% GET_NSLICE will fetch the number of slices, according to data.sequence
%
% SYNTAX
%       nSlice = FARM.SEQUENCE.GET_NSLICE( data )
%
% INPUTS
%       - data : see <a href="matlab: help farm_check_data">farm_check_data</a>
%

if nargin==0, help(mfilename('fullpath')); return; end


%% Main

if isfield(data.sequence,'MB')
    nSlice = data.sequence.nSlice / data.sequence.MB;
else
    nSlice = data.sequence.nSlice;
end


end % function
