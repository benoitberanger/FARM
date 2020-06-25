function pathstr = get_path( data )

% Prepare output filename fullpath
[pathstr, ~, ~] = fileparts(data.cfg.dataset);

% Use cfg.outdir.png if defined
png_dir = farm.io.get_subfield( data, 'cfg.outdir.png');
if ~isempty( png_dir ), pathstr = png_dir; end

end % function
