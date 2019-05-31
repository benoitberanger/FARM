function data = farm_adaptive_noise_cancellation( data )
% FARM_ADAPTIVE_NOISE_CANCELLATION
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
    
    clean_channel = lpf_channel - y';
    
    % Store
    data.anc_clean(iChannel, start_onset:stop_onset) = clean_channel;
    data.anc_noise(iChannel, start_onset:stop_onset) = y;
    
end % iChannel


end % function
