%% Init

clear
clc

assert( ~isempty(which('ft_preprocessing')), 'FieldTrip library not detected. Check your MATLAB paths, or get : https://github.com/fieldtrip/fieldtrip' )
assert( ~isempty(which('farm_rootdir'))    ,      'FARM library not detected. Check your MATLAB paths, or get : https://github.com/benoitberanger/FARM' )

% Initialize FieldTrip
ft_defaults


%% Get file & sequence paramters

sampledata_path = fullfile(farm_rootdir,'sample_dataset');
fname     = 'me3mb3_tr1600_sl54';
fname_eeg = fullfile(sampledata_path, [fname '.eeg' ]);
fname_hdr = fullfile(sampledata_path, [fname '.vhdr']);
fname_mrk = fullfile(sampledata_path, [fname '.vmrk']);

sequence.TR     = 1.6; % in seconds
sequence.nSlice = 54;
sequence.MB     = 3;   % multiband factor
sequence.nVol   = [];  % integer or NaN, if [] it means use all volumes
% Side note : if the fMRI sequence has been manually stopped, the last volume will probably be incomplete.
% But this incomplete volume will stil generate a marker. In this case, you need to define sequence.nVol or use farm_remove_last_volume_event()

MRI_trigger_message = 'R128';

% In this sample dataset, channels are { 'EXT_D' 'FLE_D' 'EXT_G' 'FLE_G' }
% FARM will be performed on all 4 channels, so I create a regex that will fetch them :
channel_regex = 'EXT|FLE';


%% Load data
% Optimal length for a dataset is a bunch of seconds before the start of
% the fmri sequence, and a bunch of seconds after the end of the fmri
% sequence, before any other sequence.

% Read header & events
cfg           = [];
cfg.dataset   = fname_hdr;
raw_event     = ft_read_event (fname_mrk);
event         = farm_change_marker_value(raw_event, MRI_trigger_message, 'V'); % rename volume marker, just for comfort
event         = farm_delete_marker(event, 'Sync On');                          % not useful for FARM, this marker comes from the clock synchronization device
event         = farm_remove_last_volume_event( event, 'V' );                   % remove last incomplete volume, becasue of manually stopped sequence

% Load data
data                    = ft_preprocessing(cfg); % load data
data.cfg.event          = event;                 % store events
data.sequence           = sequence;              % store sequence parameters
data.volume_marker_name = 'V';                   % name of the volume event in data.cfg.event

% Some paramters tuning
data.cfg.intermediate_results_overwrite = false; % don't overwrite files
data.cfg.intermediate_results_save      = true;  % write on disk intermediate results
data.cfg.intermediate_results_load      = true;  % if intermediate result file is detected, to not re-do step and load file

% Output directory
% If no outdir is defined, use the same as inputdir
outdir = tempdir(); % tempdir() is a matlab built-in function to get the temporary directory, which is emptied at each reboot
data.cfg.outdir.intermediate = fullfile( outdir, 'FARM_intermediate'); % intermediate results
data.cfg.outdir.BVAexport    = fullfile( outdir, 'FARM_BVAexport'   ); % export final results in {.eeg, .vhdr, .vmrk}
data.cfg.outdir.MATexport    = fullfile( outdir, 'FARM_MATexport'   ); % export final results in .mat
data.cfg.outdir.png          = fullfile( outdir, 'FARM_png'         ); % write PNG here, for visual quick check
data.cfg.outdir.regressor    = fullfile( outdir, 'FARM_regressor'   ); % write regressor here, in .mat

% Plot
% ft_databrowser(data.cfg, data)


%% ------------------------------------------------------------------------
%% FARM main workflow is wrapped in this function:

data = farm_main_workflow( data, channel_regex );


%% ------------------------------------------------------------------------
%% Plot

% Raw
farm_plot_carpet     (data, channel_regex, 'raw'      , +[30 250])
farm_plot_FFT        (data, channel_regex, 'raw'      , +[30 250])
farm_plot_spectrogram(data, channel_regex, 'raw'      , +[30 250])

% After processing
farm_plot_carpet     (data, channel_regex, 'pca_clean', +[30 250])
farm_plot_FFT        (data, channel_regex, 'pca_clean', +[30 250])
farm_plot_spectrogram(data, channel_regex, 'pca_clean', +[30 250])


%% Convert clean EMG to regressors & save them

% Use 1 channel : EXT_D
ts      = farm_get_timeseries( data, 'EXT_D', 'pca_clean', +[30 250] );              % (1 x nSamples)
reginfo = farm_emg_regressor ( data, ts, 'EXT_D' );
farm_plot_regressor( data, reginfo)
farm_save_regressor( data, reginfo)

% Use 1 channel : FLE_D
ts      = farm_get_timeseries( data, 'FLE_D', 'pca_clean', +[30 250] );              % (1 x nSamples)
reginfo = farm_emg_regressor ( data, ts, 'FLE_D' );
farm_plot_regressor( data, reginfo)
farm_save_regressor( data, reginfo)

% Use 2 channels and combine them : EXT_D + FLE_D
ts      = farm_get_timeseries( data, {'EXT_D','FLE_D'}, 'pca_clean', +[30 250] ); % (2 x nSamples)
reginfo = farm_emg_regressor ( data, ts, 'EXTFLE_D', 'mean' );
farm_plot_regressor( data, reginfo)
farm_save_regressor( data, reginfo)


%% Export final results to different formats

farm_export_BVA( data ) % BrainVisionAnalyzer ( .eeg, .vhdr, .vmrk )
farm_export_mat( data ) % MATLAB ( .mat )


%% Print figures

figH = farm_plot_FFT(data, [], 'pca_clean', +[30 250]);
farm_print_figure( data, figH ); % close(figH)

