function farm_print_figure( data, figH )


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
