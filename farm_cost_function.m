function cost = farm_cost_function( current_param, speed, const )
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

if isempty(speed)
    speed = 1;
end

%% Parameters

% Shortucts
onset_first_volume = const.onset_first_volume;
signal             = const.signal;
fsample            = const.fsample;
nVol               = const.nVol;
nSlice             = const.nSlice;
isvolume           = const.isvolume;
good_slice_idx     = const.good_slice_idx;

% Speed managment : higher speed, less slice-segement used for cost computation
good_slice_idx     = good_slice_idx(1:speed:end) ;

% Get new estimated paramters
sdur  = current_param(1);
dtime = current_param(2);


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


%% Prepare slice-segment with some padding for the phase-shifting
% Here, we only take into account the "good" slices that will be used for
% the slice-correction

% For the phase-shifting, we need pad the slice-segement data with some extra points.
% The phase-shift is supposed to be half a sample, so we don't need to add a lot of padding

padding = 10; % samples

slice_segement = zeros( length(good_slice_idx), round(sdur * fsample) + padding );

for iSlice = 1 : length(good_slice_idx)
    slice_segement(iSlice,:) = signal( slice_onset(good_slice_idx(iSlice)) - padding/2 : slice_onset(good_slice_idx(iSlice)) + round(sdur * fsample) - 1 + padding/2 );
end


%% Adjust slice onset with phase-shift using FFT

delta_t        = round_error(good_slice_idx) / sdur / fsample;
slice_segement = farm_phase_shift( slice_segement , delta_t );


%% Remove padding

slice_segement = slice_segement(:,1+padding/2 : end-padding/2);

% If you want to "see" the effect of sdur & dtime optimization, uncomment the lines bellow.
% *************************************************************************
% figPtr = findall(0,'Tag',mfilename); % Is the figure already open ?
% if ~isempty(figPtr) % Figure exists so brings it to the focus
%     figure(figPtr);
% else % Create the figure
%
%     % Create a figure
%     figure( ...
%         'Name'            , mfilename                , ...
%         'NumberTitle'     , 'off'                    , ...
%         'Tag'             , mfilename                );
% end
% % image(slice_segement,'CDataMapping','scaled'), colormap(gray(256));
% plot(std(slice_segement))
% drawnow
% *************************************************************************


%% Sum of Variance == cost

slice_segement = ft_preproc_standardize(slice_segement); % z-transform, to normalize the amplitudes
cost           = mean( std(slice_segement) );            % use mean() instead of sum() to normalize alose

fprintf('current sdur | dtime : %fµs %fµs - TR : %fs - cost : %f - speed : %d \n', ...
    current_param(1)*1e6, current_param(2)*1e6, const.nSlice*current_param(1) + current_param(2), cost, speed)


end % function
