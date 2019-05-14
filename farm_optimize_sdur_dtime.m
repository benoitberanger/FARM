function data = farm_optimize_sdur_dtime( data )
% FARM_OPTIMIZE_SDUR_DTIME will use the previously computed sdur_v & dtime_v,
% as initializing point to optimize the final sdur & dtime
%
% Ref : Van der Meer, J. N., Tijssen, M. A. J., Bour, L. J., van Rootselaar, A. F., & Nederveen, A. J. (2010).
%       Robust EMG–fMRI artifact reduction for motion (FARM).
%       Clinical Neurophysiology, 121(5), 766–776.
%       https://doi.org/10.1016/j.clinph.2009.12.035
%

if nargin==0, help(mfilename); return; end

%% Paramters

hpf          = 250; % hertz
interpfactor = 10;  % interpolation factor : upsampling

% Shortcuts
sequence           = data.sequence;
volume_marker_name = data.volume_marker_name;


%% Retrive some variables already computed
% computed by farm_add_slice_marker

sdur_v  = data.sdur_v;
dtime_v = data.dtime_v;

%% Define some other variables

volume_event = ft_filter_event(data.cfg.event,'value',volume_marker_name);

onset_first_volume = volume_event(1).sample;
% onset_last_volume  = volume_event(end).sample + data.fsample*sequence.TR + round(mean(sdur_v)); % last marker onset + 1 TR + 1 sdur


%% Prepare time serie we will be working on

data = farm_detect_channel_with_greater_artifact( data ); % simple routine, defines data.target_channel

% Remove low frequencies, including EMG, we only need the gradients
hpf_target_channel = ft_preproc_highpassfilter(...
    data.trial{1}(data.target_channel,:), ...
    data.fsample                   , ...
    hpf                            );

% hpf_target_channel = hpf_target_channel(onset_first_volume : onset_last_volume);
% new_data_time      = data.time{1}(onset_first_volume) : 1/(data.fsample*interpfactor) : data.time{1}(onset_last_volume);
new_data_time      = data.time{1}(1) : 1/(data.fsample*interpfactor) : data.time{1}(end);


% Upsample, using matlab builtin function 'interp1'. 'pchip' = shape-preserving piecewise cubic interpolation
% Note : ft_resampledata uses the same function 'interp1'
signal = interp1( data.time{1}, hpf_target_channel, new_data_time, 'pchip' );
signal = [ signal zeros(1, length(signal)) ]; % padding

% 'signal' is now an upsmapled time serie, containing only the gradients artifacts, no EMG
% We will use this 'signal' to optimize the sdur and dtime paramters


%% Optimization
% sdur & dtime precision greatly impacts the quality of the template correction.
% The article presents a strategy to determine sdur & dtime with high precision.
% How ? use unconstrained nonlinear optimization, where the cost function is similar
% to the Sum of Variance SV ( eq(2) ), but computed for all volumes, not volume-per-volume.

% Initialization of parameters to optimize
init_param    = [mean(sdur_v) mean(dtime_v)] / data.fsample; % we need a vector of paramters in order to use 'fminsearch'
% sdur & dtime are expressed in seconds, to avoid sampling mismatch

% cost function constant variables
const                    = struct;
const.onset_first_volume = onset_first_volume*interpfactor;
const.signal             = signal;
const.fsample            = data.fsample*interpfactor;
const.nVol               = length(volume_event);
if isfield(sequence,'MB')
    const.nSlice         = sequence.nSlice / sequence.MB;
else
    const.nSlice         = sequence.nSlice;
end
const.isvolume           = data.slice_info.isvolume;
const.good_slice_idx     = data.slice_info.good_slice_idx;

options = optimset('Display','iter-detailed');

% fminsearch
tic
[x,fval,exitflag,output] = fminsearch( @(param) cost_function(param, const), init_param, options );
toc

end % function


function cost = cost_function( current_param, const )
% Optimization cost function
%
% This function will use eq(3) from the article to build the new slice onsets,
% and take into account the rounding error. |rounding error| < sample/2
%
% The rounding error will be taken into account and used to adjust the slice onset
% using phase shifting, implimented here with FFT.
%
% This rounding error correction is inside the optimization process to reduce even further
% the mismatch between slice-artifacts and artifact-templates


%% Parameters

% Shortucts
onset_first_volume = const.onset_first_volume;
signal             = const.signal;
fsample            = const.fsample;
nVol               = const.nVol;
nSlice             = const.nSlice;
isvolume           = const.isvolume;
good_slice_idx     = const.good_slice_idx;

% Get new estimated paramters
sdur  = current_param(1);
dtime = current_param(2);

fprintf('%.6f ms %.6f ms \n', sdur*1000, dtime*1000)


%% Build new slice onsets & rounding error
% based on eq(3) in the article

slice_onset = zeros( nSlice * nVol, 1 );
round_error = zeros( nSlice * nVol, 1 );

for iSlice = 1 : nSlice * nVol
    
    iVolume   = sum( isvolume(1:iSlice) );
    
    slice_onset(iSlice) = onset_first_volume + ( ( iSlice - 1 ) * sdur + (iVolume - 1) * dtime ) * fsample;
    round_error(iSlice) = slice_onset(iSlice) - round(slice_onset(iSlice));
    slice_onset(iSlice) = round(slice_onset(iSlice));
    
end


%% Adjust slice onset with phase-shift using FFT

% For the phase-shifting, we pad the slice-segement data with some extrapoints
% The phase shift is supposed to be half a sample, so we don't need to add a lot of padding
padding = 10; % samples

for iSlice = 1 : nSlice * nVol
    
    in      = signal( slice_onset(iSlice)-padding/2 : slice_onset(iSlice)+round(sdur * fsample)+padding/2 );
    delta_t = round_error(iSlice) / sdur / fsample ;
    out     = phase_shift( in, delta_t );
    
    signal( slice_onset(iSlice) : slice_onset(iSlice)+round(sdur * fsample) ) = out( 1+padding/2 : end-padding/2 );
    
end


%% Prepare the slice-segment for the computation of Sum of Variance
% Here, we only take into account the "good" slices that will be used for
% the slice-correction

slice_segements = zeros(length(good_slice_idx),round(sdur * fsample));

for iSlice = 1 : length(good_slice_idx)
    slice_segements(iSlice,:) = signal( slice_onset(good_slice_idx(iSlice)) : slice_onset(good_slice_idx(iSlice)) + round(sdur * fsample) - 1 );
end


%% Sum of Variance
% Sum of Variance == cost

SV   = sum(std(slice_segements));
cost = SV ^ 2; % for faster convergence

end % function

function out = phase_shift( in, delta_t )
% I don't understand why implemntation works, and not the one described in
% https://stackoverflow.com/questions/31586803/delay-a-signal-in-time-domain-with-a-phase-change-in-the-frequency-domain-after

Y = fft(in);

adjustment = zeros(1,length(in));
n          = floor(length(adjustment)/2);

adjustment(2:n+1)          = 1:n;
adjustment(end:-1:end-n+1) = -(1:n);
if ~rem(length(in),2)
    adjustment(length(adjustment)/2 + 1) = 0;
end

out = ifft( Y .* exp( 1i*2*pi* delta_t * adjustment ) );

end % function

