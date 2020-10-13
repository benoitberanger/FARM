function nSlice = get_nSlice( self )
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

if isfield(self.data.sequence,'MB')
    nSlice = self.data.sequence.nSlice / self.data.sequence.MB;
else
    nSlice = self.data.sequence.nSlice;
end


end % function
