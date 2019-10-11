function rootdir = farm_rootdir( )
% FARM_ROOTDIR returns the fullpath of FARM root directory
%
% SYNTAX
%       rootdir = FARM_ROOTDIR()
%

if nargin==0, help(mfilename('fullpath')); return; end

%% Main

rootdir = fileparts( mfilename('fullpath') );


end % function
