function fname = get_fname( data, calling_function )

% The calling_function is used for the filename
suffix = strrep(calling_function,'farm_','_');

% Prepare output filename fullpath
[pathstr, name, ~] = fileparts(data.cfg.dataset);

% Use cfg.outdir.intermediate if defined
intermediate_dir = farm.io.get_subfield( data, 'cfg.outdir.intermediate');
if ~isempty( intermediate_dir ), pathstr = intermediate_dir; end

fname = fullfile(pathstr, [name suffix '.mat']);

end % function
