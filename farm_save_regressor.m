function farm_save_regressor( data, reginfo )
% FARM_SAVE_REGRESSOR will save regressor on disk
% Output directory is -> data.cfg.outdir.regressor
%                  or -> same dir as input .eeg file
%
% SYNTAX
%       FARM_SAVE_REGRESSOR( data, reginfo )
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


%% Fetch data prepare output dir

path = farm.io.regressor.get_path(data);
if ~exist(path, 'dir'), mkdir(path), end
[~, dataset_name, ~] = fileparts(data.cfg.dataset);


%% Loop for all kind of regressors/modulators to save

list = {'reg', 'dreg', 'log_reg', 'dlog_reg', 'mod', 'log_mod', 'dmod', 'dlog_mod'};

for regname = list
    %% Prepare output name
    
    fname = [dataset_name '__' reginfo.name '__' char(regname)];
    fpath = fullfile(path,[fname '.mat']);
    
    
    %% Perpare what to save
    
    tosave = struct;
    
    %--------------------------------------------------------------------------
    % For SPM
    
    R      = [];
    R(:,1) = reginfo.(char(regname));
    
    names    = cell(1,1);
    names(1) = regname;
    
    tosave.R     = R;
    tosave.names = names; %#ok<*STRNU>
    
    %--------------------------------------------------------------------------
    % Other things to save
    
    
    %% Save
    
    fprintf('[%s]: writing file : %s \n', mfilename, fpath)
    save(fpath,'-struct','tosave')
    
    
end % regname


end % function
