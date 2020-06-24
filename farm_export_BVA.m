function farm_export_BVA( data, processing_stage )
% FARM_EXPORT_BVA will write on disk the desired processing step in BrainVision Analyzer format
% 3 files will be created : .eeg, .vhdr, .vmrk
%
% SYNTAX
%       FARM_EXPORT_BVA( data                   )
%       FARM_EXPORT_BVA( data, processing_stage )
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

fname = farm.io.bva.get_fname(data, stage);

% Make sure to never overwrite the input
assert( strcmp( fname, data.cfg.datafile ) == 0, 'BVAexport filename and input filename are the same ! Nerver overwrite the input.')


%% Write

fprintf('[%s]: writing file : %s (.vhdr, .vmrk)\n', mfilename, fname)
ft_write_data(fname, datapoints, 'dataformat','brainvision_eeg', 'header',data.hdr, 'event', data.cfg.event)


end % function
