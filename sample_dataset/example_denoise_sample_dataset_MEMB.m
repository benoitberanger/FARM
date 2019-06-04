%% Init

clear
clc

assert( ~isempty(which('ft_preprocessing')), 'FieldTrip library not detected. Check your MATLAB paths, or get : https://github.com/fieldtrip/fieldtrip' )
assert( ~isempty(which('farm_rootdir'))    ,      'FARM library not detected. Check your MATLAB paths, or get : https://github.com/benoitberanger/FARM' )

sampledata_path = fullfile(farm_rootdir,'sample_dataset');
fname     = 'me3mb3_tr1600_sl54';
fname_eeg = fullfile(sampledata_path, [fname '.eeg' ]);
fname_hdr = fullfile(sampledata_path, [fname '.vhdr']);
fname_mrk = fullfile(sampledata_path, [fname '.vmrk']);

sequence.TR     = 1.6; % in seconds
sequence.nSlice = 54;
sequence.MB     = 3;   % multiband factor
sequence.nVol   = []; % integer or NaN


%% Load data
% Optimal length for a dataset is a bunch of seconds before the start of
% the fmri sequence, and a bunch of seconds after the end of the fmri
% sequence, before any other sequence.

% Read header & events
cfg           = [];
cfg.dataset   = fname_hdr;
raw_event     = ft_read_event (fname_mrk);
event         = farm_change_marker_value(raw_event, 'R128', 'V');
event         = farm_delete_marker(event, 'Sync On'); % not useful

% Load data
data                    = ft_preprocessing(cfg); % load data
data.cfg.event          = event;                 % store events
data.sequence           = sequence;              % store sequence parameters
data.volume_marker_name = 'V';                   % name of the volume event in data.cfg.event

% Plot
% ft_databrowser(data.cfg, data)


%% FARM
% Main FARM functions are below.


%% Check input data, detrend, HPF @ 30Hz
% HPF @ 30 Hz removes the artifact due to electrode movement iside the static magnetic field B0
% This filtering step is MANDATORY for EMG, or any electrode with moving in B0
% I have to test/develop to check if FARM actual pipeline is feasable for EEG

farm_check_data( data )
data.trial{1} = farm_filter(data.trial{1}, data.fsample, +30); % instead of default=6 because unstable


%% Add slice markers : initialize sdur & dtime

data = farm_add_slice_marker( data );


%% Prepare which slices to use for template used in the slice-correcton

data = farm_pick_slice_for_template( data );


%% Optimize slice markers : optimize sdur & dtime

data = farm_optimize_sdur_dtime( data );


%% Slice correction : compute slice template

data = farm_compute_slice_template( data );


%% volume correction

data = farm_volume_correction( data );


%% Revove noise residuals using PCA

data = farm_optimize_slice_template_using_PCA( data );


%% Revove noise residuals using PCA
% Don't know why ANC diverges
% Clue : in Niazy et al., they think the filtering diverges when the amplitude is large,
% which is the case for EMG burst compared to EEG.

% data = farm_adaptive_noise_cancellation( data );


%% Remove slice markers

data = farm_remove_slice_marker( data );


%% Plot

farm_plotFFT(data, +[30 250])
