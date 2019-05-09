%% Init

clear
clc

assert( ~isempty(which('ft_preprocessing')), 'FieldTrip library not detected. Check your MATLAB paths, or get : https://github.com/fieldtrip/fieldtrip' )

sampledata_path = fullfile(farm_rootdir, 'sample_dataset');
fname     = 'mb6_tr1000_sl72';
fname_eeg = fullfile(sampledata_path, [fname '.eeg' ]);
fname_hdr = fullfile(sampledata_path, [fname '.vhdr']);
fname_mrk = fullfile(sampledata_path, [fname '.vmrk']);

sequence.TR     = 1.000; % in seconds
sequence.nSlice = 72;
sequence.MB     = 6;   % multiband factor
sequence.nVol   = NaN; % integer or NaN


%% Load data
% Optimal length for a dataset is a bunch of seconds before the start of
% the fmri sequence, and a bunch of seconds after the end of the fmri
% sequence, before any other sequence.

% Read header & events
cfg         = [];
cfg.dataset = fname_hdr;
cfg.channel = {'ECR_ma' 'FCR_ma' 'ECR_la' 'FCR_la'}; % channels of interest : EMG
raw_header  = ft_read_header(fname_hdr);
raw_event   = ft_read_event (fname_mrk);
event       = farm_change_marker_value(raw_event, 'R  1', 'V');

% Load data
data           = ft_preprocessing(cfg);       % load data
data.cfg.event = event;

% Plot
% ft_databrowser(data.cfg, data)


%% FARM
% Main FARM functions are below.


%% Step 0 : Check input data

farm_check_data    ( data     )
farm_check_sequence( sequence )


%% Step 1 : Add slice markers

data = farm_add_slice_marker( data, sequence, 'V');
ft_databrowser(data.cfg, data);

