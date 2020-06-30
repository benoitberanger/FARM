function farm_print_figure( data, figH )
% FARM_PRINT_FIGURE will write figures in PNG
% Output directory is -> data.cfg.outdir.PNGexport
%                  or -> same dir as input .eeg file
%
% SYNTAX
%       FARM_PRINT_FIGURE( data, figH )
%
% INPUTS
%       - data : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - figH : figure handle : this is the outpur of all farm_plot_* functions
%
% EXAMPLE
%       figH = farm_plot_FFT(data, [], 'pca_clean', +[30 250]);
%       FARM_PRINT_FIGURE( data, figH ); % close(figH)
%
%

if nargin==0, help(mfilename('fullpath')); return; end


%% Fetch data & prepare output name

type = figH.UserData; % Name of the plot function (like farm_plot_FFT)

path = farm.io.png.get_path(data);
if ~exist(path, 'dir'), mkdir(path), end

[~, dataset_name, ~] = fileparts(data.cfg.dataset);


%% Write

figH.Position = [0 0 1200 800]; % Bigger figure so the saved PNG is not too small

for tab = 1 : numel(figH.Children.Children)
    
    % Switch tab
    figH.Children.SelectedTab = figH.Children.Children(tab);
    
    % Transform title to valid file name
    figTitle = figH.Children.SelectedTab.Title;
    validName = matlab.lang.makeValidName(figTitle);
    
    fname = [dataset_name '__' type '__' validName];
    fpath = fullfile(path,[fname '.png']);
    
    fprintf('[%s]: writing file : %s \n', mfilename, fpath)
    saveas(figH, fpath)
    
end % tab


end % function
