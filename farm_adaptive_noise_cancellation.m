function data = farm_adaptive_noise_cancellation( data )
% FARM_ADAPTIVE_NOISE_CANCELLATION
%
% Ref : Van der Meer, J. N., Tijssen, M. A. J., Bour, L. J., van Rootselaar, A. F., & Nederveen, A. J. (2010).
%       Robust EMG–fMRI artifact reduction for motion (FARM).
%       Clinical Neurophysiology, 121(5), 766–776.
%       https://doi.org/10.1016/j.clinph.2009.12.035
%
%       R.K. Niazy, C.F. Beckmann, G.D. Iannetti, J.M. Brady, and S.M. Smith
%       Removal of FMRI environment artifacts from EEG data using optimal basis sets
%       NeuroImage 28 (2005) 720 – 737
%       https://doi.org/10.1016/j.neuroimage.2005.06.067
%
%       P.J. Allen, O. Josephs, R. Turner
%       A Method for Removing Imaging Artifact from Continuous EEG Recording during Functional MRI
%       NeuroImage 12, 230-239 (2000).
%       https://doi.org/10.1006/nimg.2000.0599
%



%% Parameters

lpf = 250; % Hertz


%% Retrive some variables already computed

fsample        = data.fsample;
sdur           = data.sdur;
slice_onset    = data.slice_onset; % keep non integer
sequence       = data.sequence;
if isfield(sequence,'MB')
    nSlice     = sequence.nSlice / sequence.MB;
else
    nSlice     = sequence.nSlice;
end
TR             = sequence.TR;


%% Main

nChannel = length(data.cfg.channel);

% Pre-allocation of output
data.anc_clean = data.pca_clean;
data.anc_noise = data.pca_noise;

for iChannel = 1 : nChannel
    
    fprintf('[%s]: ANC on channel %d/%d \n', mfilename, iChannel, nChannel)
    
    % Which points to get ?
    start_onset = round(slice_onset(1  )                 );
    stop_onset  = round(slice_onset(end) + 1*sdur*fsample);
    
    % Get data
    input_channel = data.pca_clean(iChannel, start_onset:stop_onset);
    input_noise   = data.pca_noise(iChannel, start_onset:stop_onset);
    
    lpf_channel = ft_preproc_lowpassfilter( input_channel, fsample, lpf );
    lpf_noise   = ft_preproc_lowpassfilter( input_noise  , fsample, lpf );
    
    hpf_lpf_channel = ft_preproc_highpassfilter( lpf_channel, fsample, nSlice/(TR*2) );
    
    d    = hpf_lpf_channel';
    refs = lpf_noise';
    
    % Adapt noise amplitude
    alpha = sum(d .* refs) / sum( refs .* refs );
    refs  = alpha * refs;
    
    N  = round(sdur*fsample);
    mu = 0.05 / (N * var(refs));
    
    [~,y]=fastranc(refs,d,N,mu);
    
    % Store
    if max(y) > 1e6 % works better than isinf
        fprintf('[%s]:ANC Failed for channel %d. Skipping ANC. \n',mfilename,iChannel);
    else
        data.anc_clean(iChannel, start_onset:stop_onset) = lpf_channel - y';
        data.anc_noise(iChannel, start_onset:stop_onset) =               y';
    end
    
end % iChannel


end % function
