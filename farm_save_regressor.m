function farm_save_regressor( data, reginfo )
% FARM_SAVE_REGRESSOR will save regressor on disk
% Output directory is -> data.cfg.outdir.regressor
%                  or -> same dir as input .eeg file
%
% SYNTAX
%       FARM_SAVE_REGRESSOR( data, reginfo, outputname )
%
% INPUT
%       - data       : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - reginfo    : see <a href="matlab: help farm_make_regressor">farm_make_regressor</a>
%                       
%
% See also farm_make_regressor farm_emg_regressor farm_acc_regressor farm_plot_regressor

if nargin==0, help(mfilename('fullpath')); return; end


%% Check

narginchk(2,2)


%% Fetch data & prepare output name

path = farm.io.regressor.get_path(data);
if ~exist(path, 'dir'), mkdir(path), end
[~, dataset_name, ~] = fileparts(data.cfg.dataset);

fname = [dataset_name '__' reginfo.name];
fpath = fullfile(path,[fname '.mat']);


%% Perpare what to save

tosave = struct;

%--------------------------------------------------------------------------
% For SPM

R      = [];
R(:,1) = reginfo. reg;
R(:,2) = reginfo.dreg;

names    = cell(2,1);
names{1} =      reginfo.name ;
names{2} = ['d' reginfo.name];

tosave.R     = R;
tosave.names = names; %#ok<*STRNU>

%--------------------------------------------------------------------------
% Other things to save


%% Save

fprintf('[%s]: writing file : %s \n', mfilename, fpath)
save(fpath,'-struct','tosave')


end % function
