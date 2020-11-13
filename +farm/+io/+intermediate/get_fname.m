function fname = get_fname( data, calling_function )

% Prepare output filename fullpath
[pathstr, name, ~] = fileparts(data.cfg.dataset);

% Use cfg.outdir.intermediate if defined
intermediate_dir = farm.io.get_subfield( data, 'cfg.outdir.intermediate');
if ~isempty( intermediate_dir ), pathstr = intermediate_dir; end

fname = fullfile(pathstr, [name '_intermediate_' calling_function '.mat']);

end % function
