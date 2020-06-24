function fname = get_fname( data, stage )

% Prepare output filename fullpath
[pathstr, name, ~] = fileparts(data.cfg.dataset);

% Use cfg.outdir.BVAexport if defined
BVAexport_dir = farm.io.get_subfield( data, 'cfg.outdir.BVAexport');
if ~isempty( BVAexport_dir ), pathstr = BVAexport_dir; end

fname = fullfile(pathstr, [name '_' stage '.eeg']);

end % function
