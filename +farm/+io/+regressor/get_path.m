function pathstr = get_path( data )

% Prepare output filename fullpath
[pathstr, ~, ~] = fileparts(data.cfg.dataset);

% Use cfg.outdir.png if defined
regressor_dir = farm.io.get_subfield( data, 'cfg.outdir.regressor');
if ~isempty( regressor_dir ), pathstr = regressor_dir; end

end % function
