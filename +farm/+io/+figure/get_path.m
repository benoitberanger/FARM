function pathstr = get_path( data )

% Prepare output filename fullpath
[pathstr, ~, ~] = fileparts(data.cfg.dataset);

% Use cfg.outdir.figure if defined
fig_dir = farm.io.get_subfield( data, 'cfg.outdir.figure');
if ~isempty( fig_dir ), pathstr = fig_dir; end

end % function
