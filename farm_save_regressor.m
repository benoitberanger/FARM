function farm_save_regressor( data, reginfo, outputname )
% FARM_SAVE_REGRESSOR will save regressor on disk
%
% SYNTAX
%       FARM_SAVE_REGRESSOR( data, reginfo, outputname )
%
% INPUT
%       - data       : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - reginfo    : see <a href="matlab: help farm_make_regressor">farm_make_regressor</a>
%       - outputname : 'char' 1) if outname is a "normal" char like 'EXT_D', the file will be /path/to/dataset/EXT_D.mat
%                             2) is outname is a "fullpath" like /path/to/whatever/myRegressor, this fullpath will be used
%                       
%
% See also farm_make_regressor farm_emg_regressor farm_acc_regressor farm_plot_regressor

if nargin==0, help(mfilename('fullpath')); return; end


%% Check

narginchk(3,3)


%% fname

[pathstr1, name, ~] = fileparts(outputname);
if isempty(pathstr1)
    [pathstr2, ~, ~] = fileparts(data.cfg.dataset);
    pathstr = pathstr2;
else
    pathstr = pathstr1;
end

fname = fullfile(pathstr,name);


%% Perpare what to save

tosave = struct;

%--------------------------------------------------------------------------
% For SPM

R      = [];
R(:,1) = reginfo. reg;
R(:,2) = reginfo.dreg;

names    = cell(2,1);
names{1} =      name ;
names{2} = ['d' name];

tosave.R     = R;
tosave.names = names; %#ok<*STRNU>

%--------------------------------------------------------------------------
% Other things to save


%% Save

save(fname,'-struct','tosave')


end % function
