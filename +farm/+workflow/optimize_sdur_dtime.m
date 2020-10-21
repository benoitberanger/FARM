function data = optimize_sdur_dtime( data, interpfactor, hpf )
% OPTIMIZE_SDUR_DTIME will use the previously computed sdur_v & dtime_v,
% as initializing point to optimize the final sdur & dtime
%
% SYNTAX
%       data = farm.workflow.OPTIMIZE_SDUR_DTIME( data, interpfactor, hpf )
%
% INPUTS
%       - data         : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - interpfactor : interpolation cator factor for upsampling
%       - hpf          : high pass filter (Hz), remove EMG and only keep MRI gradients artifacts for the optimization
%
% DEFAULTS
%       - interpfactor :  10
%       - hpd          : 250 Hz
%
%
%**************************************************************************
% Ref : Van der Meer, J. N., Tijssen, M. A. J., Bour, L. J., van Rootselaar, A. F., & Nederveen, A. J. (2010).
%       Robust EMG–fMRI artifact reduction for motion (FARM).
%       Clinical Neurophysiology, 121(5), 766–776.
%       https://doi.org/10.1016/j.clinph.2009.12.035
%
%       Jeffrey C. Lagarias, James A. Reeds, Margaret H. Wright, and Paul E Wright
%       Convergence Properties of the Nelder--Mead Simplex Method in Low Dimensions
%       December 1998 SIAM Journal on Optimization 9(1):112-147
%       https://doi.org/10.1137/S1052623496303470
%

if nargin==0, help(mfilename('fullpath')); return; end


%% Checks

narginchk(1,3)

farm_check_data( data )


%% Load

[ data, skip ]= farm.io.intermediate.load(data,mfilename);
if skip, return, end


%% Paramters

if ~exist('interpfactor','var')
    interpfactor = 10;  % interpolation factor : upsampling
end

if ~exist('hpf'         ,'var')
    hpf          = 250; % Hz
end


%% Retrive some variables already computed
% computed by farm_add_slice_marker

sdur_v  = data.sdur_v;
dtime_v = data.dtime_v;


%% Define some other variables

% Shortcuts
sequence = data.sequence;

volume_event = farm.sequence.get_volume_event( data );

onset_first_volume = volume_event(1).sample;


%% Remove low frequencies, including EMG, we only need the gradients

hpf_target_channel = ft_preproc_highpassfilter(...
    data.initial_hpf(data.target_channel,:)  , ...
    data.fsample                             , ...
    hpf                                       );

signal = farm.resample( hpf_target_channel, data.time{1}, data.fsample, interpfactor );

% To be sure to have enough points when optimization sdur & dtime, we need a longer input
signal = [ signal zeros(1, length(signal)) ]; % double the length, like a padding

% 'signal' is now an upsmapled time serie, containing only the gradients artifacts, no EMG
% We will use this 'signal' to optimize the sdur and dtime paramters


%% Optimization
% sdur & dtime precision greatly impacts the quality of the template correction.
% The article presents a strategy to determine sdur & dtime with high precision.
% How ? use unconstrained nonlinear optimization, where the cost function is similar
% to the Sum of Variance SV ( eq(2) ), but computed for all volumes, not volume-per-volume.

% Initialization of parameters to optimize
init_param    = [mean(sdur_v) mean(dtime_v)] / data.fsample; % we need a vector of paramters, as initial point
% sdur & dtime are expressed in seconds, to avoid sampling mismatch

% cost function constant variables
const                    = struct;
const.onset_first_volume = onset_first_volume*interpfactor;
const.signal             = signal;
const.fsample            = data.fsample*interpfactor;
const.nVol               = farm.sequence.get_nVol  ( data );
const.nSlice             = farm.sequence.get_nSlice( data );
const.isvolume           = data.slice_info.isfirstslice;
const.good_slice_idx     = data.slice_info.good_slice_idx;

% Unconstrained nonlinear optimization using Nelder-Mead algorithm
fprintf('[%s]: Starting sdur & dtime optimization \n', farm.io.mfilename)


% Initializiation points
%-----------------------
% In our case, we have a vector of 2 paramters x0 = [ sdur dtime ],
% but for the algorithm, we need to create 3 starting point [sdur1 dtime1; sdur2 dtime2; sdur3 dtime3],
% and the algorithm will start to look around this values.
% I choose to start with points that are a few µs next to sdur (and follow the rule dtime = TR - nSlice x sdur)
sdur  = init_param(1);
% dtime = init_param(2);

% move from starting point x0 = [ sdur dtime ] by a small bit of time (in seconds)
delta = 1e-5; % 10 µs

x_init = [
    sdur+delta , sequence.TR-const.nSlice*(sdur+delta) % sdur & dtime + delta
    sdur-delta , sequence.TR-const.nSlice*(sdur-delta) % sdur & dtime - delta
    sdur+delta , sequence.TR-const.nSlice*(sdur-delta) % sdur & dtime +-delta
    ];

% Go !
x_opt = farm.optimization.nelder_mead ( x_init,  @(param,speed) farm.optimization.cost_function(param, speed, const) );
final_param = x_opt;

fprintf('initial   sdur | dtime : %fµs %fµs - initial TR : %fs \n',  init_param(1)*1e6,  init_param(2)*1e6, const.nSlice* init_param(1) +  init_param(2) )
fprintf('final     sdur | dtime : %fµs %fµs - final   TR : %fs \n', final_param(1)*1e6, final_param(2)*1e6, const.nSlice*final_param(1) + final_param(2))
fprintf('variation sdur | dtime : %fµs %fµs \n', (final_param(1)-init_param(1))*1e6, (final_param(2)-init_param(2))*1e6)

sdur  = final_param(1);
dtime = final_param(2);

data.sdur  = sdur;
data.dtime = dtime;


%% Store new slice onsets, using original fsample
% Note : they are stored as float

nVol     = const.nVol;
nSlice   = const.nSlice;
isvolume = const.isvolume;
fsample  = data.fsample;   % original fsample

slice_onset = zeros( nSlice * nVol, 1 ); % this a float, not an integer
round_error = zeros( nSlice * nVol, 1 ); %  -0.5 < round_error < +0.5 sample

for iSlice = 1 : nSlice * nVol
    
    iVolume = sum( isvolume(1:iSlice) );
    
    slice_onset(iSlice) = onset_first_volume + ( ( iSlice - 1 ) * sdur + (iVolume - 1) * dtime ) * fsample;
    round_error(iSlice) = slice_onset(iSlice) - round(slice_onset(iSlice));
    
end

data.slice_onset = slice_onset;
data.round_error = round_error;

data.interpfactor = interpfactor;

fprintf('[%s]: Optimization sdur & dtime done \n', farm.io.mfilename)


%% Save

farm.io.intermediate.save(data,mfilename,'sdur','dtime','slice_onset','round_error','interpfactor')


end % function
