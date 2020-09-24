function best = farm_select_best_emg_using_acc_coherence( data, cfg )



%% Input parsing

% foi = ft_getopt(cfg, 'foi', [4 6]); %  (Hz) frequency of interest


%% Get EMG/ACC prepared data

[data_emg_acc, info] = farm.tfa.prepare_emg_acc( data, cfg );


%% Coherence

coh = farm.tfa.perform_coherence_analysis( data_emg_acc, cfg );


%% Select best candidate

% foi_idx = coh.freq >= foi(1) & coh.freq <= foi(2); % Get frequency of interest
% img = mean(coh.cohspctrm(:,:,foi_idx),3);          % average Fourier coefficients @ frequency of interest
img = mean(coh.cohspctrm,3);                        % average Fourier coefficients

acc_idx_in_img = contains( coh.label, info.channel_name_acc); % Fetch ACC channel index

sum_acc_img = sum( img(:,acc_idx_in_img) , 2 ); % Sum ACC coherence for all channels
sum_acc_img(acc_idx_in_img) = 0;                % Exlude ACC channels, only keep EMG for the selection

% Selection
[~,I] = max(sum_acc_img);
best_chan_name = coh.label{I};
fprintf('\n\n[%s]: Best EMG channel is >> %s << \n\n', mfilename, best_chan_name)


%% TFA

TFA = farm.tfa.perform_time_frequency_analysis( data_emg_acc, cfg );


%% Post-processing

TFA = farm.tfa.postprocessing( TFA, cfg );


%% Output

% main stuff to save
best.label     = best_chan_name;
best.peakfreq  = TFA.peakfreq (I);
best.peakpower = TFA.peakpower(I,:);
best.time      = TFA.time;
best.fsample   = 1/mean(diff(TFA.time));

% diagnostic stuff to save
best.powspctrm   = squeeze( TFA.powspctrm(I,:,:) );
best.power_Tmean = TFA.power_Tmean(I,:);
best.power_Fmean = TFA.power_Fmean(I,:);


end % function
