function farm_export_mat( data, processing_stage )
% FARM_EXPORT_MAT will write on disk the desired processing step in MATLAB .mat
% Output directory is -> data.cfg.outdir.MATexport
%                  or -> same dir as input .eeg file
%
% SYNTAX
%       FARM_EXPORT_MAT( data                   )
%       FARM_EXPORT_MAT( data, processing_stage )
%
% INPUTS
%       - data             : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - processing_stage : regex for field in data, exept for 'raw' which means data.trial{1}
%
%
% NOTES
%       - if no "processing_stage" is defined, use last "*_clean"
%

if nargin==0, help(mfilename('fullpath')); return; end


%% Input parsing

if ~exist('processing_stage','var')
    processing_stage = [];
end


%% Fetch data & prepare output name

[ datapoints, ~, ~, stage ] = farm.plot.get_datapoints( data, [], processing_stage );

fname = farm.io.mat.get_fname(data, stage);

% Make sure to never overwrite the input
assert( strcmp( fname, data.cfg.datafile ) == 0, 'MATLAB export filename and input filename are the same ! Nerver overwrite the input.')


%% Write

% What to save ?
to_save = struct;
variables = {'hdr', 'label', 'time', 'trial', 'fsample', 'sampleinfo', 'cfg', ...
    'sequence', 'volume_marker_name', 'selected_channels_idx', 'selected_channels_name'};
for v = 1 : length(variables)
    to_save.(variables{v}) = data.(variables{v});
end

% Replace to_save.trial by the desired stage
to_save.trial{1} = datapoints; %#ok<STRNU>

% Save the fields of a structure as individual variables
outdir = fileparts(fname);
if ~exist( outdir, 'dir' )==7, mkdir(outdir); end
fprintf('[%s]: writing file : %s \n', mfilename, fname)
save(fname, '-struct', 'to_save')


end % function
