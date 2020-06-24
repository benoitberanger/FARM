function fname = get_fname( data, stage )

% Prepare output filename fullpath
[pathstr, name, ~] = fileparts(data.cfg.dataset);

% Use cfg.outdir.MATexport if defined
MATexport_dir = farm.io.get_subfield( data, 'cfg.outdir.MATexport');
if ~isempty( MATexport_dir ), pathstr = MATexport_dir; end

fname = fullfile(pathstr, [name '_' stage '.mat']);

end % function
