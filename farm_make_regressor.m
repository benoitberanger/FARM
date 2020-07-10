function reginfo = farm_make_regressor( timeseries, fsample, TR )
% FARM_MAKE_REGRESSOR will convolve with HRF from SPM toolbox, compute first derivative, and downsample at TR
%
% SYNTAX
%       reginfo = FARM_MAKE_REGRESSOR( in, fsample, TR )
%
% INPUT
%       - timeseries : see <a href="matlab: help farm_get_timeseries">farm_get_timeseries</a>
%       - fsample    : sampling frequency of the timeseries, in Hertz (Hz)
%       - TR         : RepetitionTime of the fMRI sequence, in seconds (s)
%
%
% See also farm_plot_regressor farm_emg_regressor

if nargin==0, help(mfilename('fullpath')); return; end


%% Checks

assert( ~isempty(which('spm_Volterra')), 'SPM library not detected. Check your MATLAB paths, or get : https://www.fil.ion.ucl.ac.uk/spm/' )

assert( size(timeseries,1)==1,  '[%s]: timeseries must be (1 x nSamples)', mfilename )

assert( ...
    isscalar        (fsample) &...
    fsample == abs  (fsample) &...
    fsample == round(fsample) , '[%s]: fsample must be positive integer' , mfilename)

assert( ...
    isscalar   (TR) &...
    TR == abs  (TR) , '[%s]: TR must be positive' , mfilename)


%% convolve with HRF

% prepare SPM syntax for convolution

U(1).u    = timeseries(:);
U(1).name = {'reg'};

U(2).u    = farm.log_transform(timeseries)';
U(2).name = {'log'};

fMRI_T     = spm_get_defaults('stats.fmri.t');
fMRI_T0    = spm_get_defaults('stats.fmri.t0');
xBF.T      = fMRI_T;
xBF.T0     = fMRI_T0;
xBF.dt     = 1/fsample; % use our sampling time
xBF.name   = 'hrf';

xBF        = spm_get_bf(xBF); % get HRF

X          = spm_Volterra(U, xBF.bf, 1); % convolution


%% Some other prepartions

conv      = X(:,1)';       % keep line, such as  (1 x nSample)
conv      = farm.normalize_range( conv);

dconv     = [0 diff(conv)]; % first derivative
dconv     = farm.normalize_range(dconv);

log_conv  = X(:,2)';       % keep line, such as  (1 x nSample)
log_conv  = farm.normalize_range(log_conv);

dlog_conv = [0 diff(log_conv)]; % first derivative
dlog_conv = farm.normalize_range(dlog_conv);


%% downsample @ TR

reg      =      conv( 1 : round(TR*fsample) : end );
dreg     =     dconv( 1 : round(TR*fsample) : end );

log_reg  =  log_conv( 1 : round(TR*fsample) : end );
dlog_reg = dlog_conv( 1 : round(TR*fsample) : end );


%% Save

reginfo           = struct;

reginfo.in        = farm.normalize_range(timeseries);
reginfo.time_in   = (0:length(timeseries)-1)/fsample;

reginfo. conv     =  conv;
reginfo.dconv     = dconv;
reginfo.time_conv = (0:length(conv)-1)/fsample;
reginfo.log_conv  =  log_conv;
reginfo.dlog_conv = dlog_conv;

reginfo. reg      =  reg;
reginfo.dreg      = dreg;
reginfo.time_reg  = (0:length(reg)-1)*TR;

reginfo. log_reg  = log_reg;
reginfo.dlog_reg  = dlog_reg;


end % function

