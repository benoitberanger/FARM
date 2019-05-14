%% Init

clear
clc

assert( ~isempty(which('ft_preprocessing')), 'FieldTrip library not detected. Check your MATLAB paths, or get : https://github.com/fieldtrip/fieldtrip' )

sampledata_path = fullfile(farm_rootdir, 'sample_dataset');
fname     = 'me3mb3_tr1600_sl54';
fname_eeg = fullfile(sampledata_path, [fname '.eeg' ]);
fname_hdr = fullfile(sampledata_path, [fname '.vhdr']);
fname_mrk = fullfile(sampledata_path, [fname '.vmrk']);

sequence.TR     = 1.6; % in seconds
sequence.nSlice = 54;
sequence.MB     = 3;   % multiband factor
sequence.nVol   = 300; % integer or NaN


%% Load data
% Optimal length for a dataset is a bunch of seconds before the start of
% the fmri sequence, and a bunch of seconds after the end of the fmri
% sequence, before any other sequence.

% In this sample dataset, the recording is much longer than the fmri scan.
% We have : nothing, shimming, 3DT1 mprage, fmri multi-echo multiband, some
% reversed PE volumes, multishell diffusion (6 scans)
% So, we want to cut our data so we only keep the real fmri scan

% Read header & events
cfg         = [];
cfg.dataset = fname_hdr;
raw_header  = ft_read_header(fname_hdr);
raw_event   = ft_read_event (fname_mrk);

% Select the volume/slice markers
volume_marker_name = 'R128';
volume_event       = ft_filter_event(raw_event,'value',volume_marker_name);
fmri_volume_event  = volume_event(1:sequence.nVol); % We know our fmri sequeunce is 300 volumes, and is the first to generate markers.

% Define a "trial" (see fieldtrip) which corresponds to the fMRI run
nSample_per_TR = raw_header.Fs * sequence.TR;                         % number of sample (datapoints) per TR
sample_begin   = fmri_volume_event(1  ).sample - 30 * nSample_per_TR; % begin = first TR minus a bunch of seconds
sample_end     = fmri_volume_event(end).sample +  3 * nSample_per_TR; % begin = last  TR plus  a bunch of seconds

% Load data
cfg.trl         = [sample_begin sample_end 0]; % only load the samples surrounding the fmri run
data            = ft_preprocessing(cfg);       % load data
data.sampleinfo = [1 sample_end-sample_begin+1];

% Keep interesting events
fmri_event     = ft_filter_event(raw_event, 'minsample', sample_begin, 'maxsample', sample_end, 'value', volume_marker_name);
fmri_event     = farm_change_marker_value( fmri_event, volume_marker_name, 'V' ); % replace marker name by 'V' for volume
fmri_event     = farm_offset_marker(fmri_event, -sample_begin);

data.cfg.event          = fmri_event;                 % store events
data.sequence           = sequence;              % store sequence parameters
data.volume_marker_name = 'V';                   % name of the volume event in data.cfg.event

% Plot
% ft_databrowser(data.cfg, data)


%% FARM
% Main FARM functions are below.


%% Step 0 - Check input data

farm_check_data( data )


%% Step 1 - Add slice markers

data = farm_add_slice_marker( data);
% ft_databrowser(data.cfg, data)


%% Step 2 - Prepare which slices to use for template used in the slice-correcton

data = farm_pick_slice_for_template( data );

