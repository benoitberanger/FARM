function fname = get_fname( data, calling_function )

% The calling_function is used for the filename
suffix = strrep(calling_function,'farm_','_');

% Prepare output filename fullpath
[pathstr, name, ~] = fileparts(data.cfg.dataset);
fname = fullfile(pathstr, [name suffix '.mat']);

end % function
