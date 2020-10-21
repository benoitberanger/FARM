function data = remove_slice_marker( data )
% REMOVE_SLICE_MARKER will remove slice markers added by FARM
%
% SYNTAX
%       data = farm.workflow.REMOVE_SLICE_MARKER( data )
%
% INPUTS
%       - data : see <a href="matlab: help farm_check_data">farm_check_data</a>
%
% See also farm_delete_marker

if nargin==0, help(mfilename('fullpath')); return; end


%% Main

data.cfg.event = farm_delete_marker( data.cfg.event, 's' );


end % function
