function data = farm_adjust_volume_marker( data )


if nargin==0, help(mfilename); return; end


%% Check input arguments

narginchk(1,1)

% data
farm_check_data( data )

% Shortcuts
sequence           = data.sequence;
volume_marker_name = data.volume_marker_name;


%% Detect the channel with higher "amplitude"

data = farm_detect_channel_with_greater_artifact( data ); % simple routine, defines data.target_channel

% Remove low frequencies, including EMG, we only need the gradients to compute slice markers
hpf_target_channel = ft_preproc_highpassfilter( ...
    data.trial{1}(data.target_channel,:)      , ...
    data.fsample                              , ...
    1, 4                                       );


%% Prepare some paramters

% nVol
volume_event = ft_filter_event(data.cfg.event,'value',volume_marker_name);
assert( numel(volume_event)>0 , '%s is not a valid marker', volume_marker_name )

% nSlice
if isfield(sequence,'MB')
    nSlice = sequence.nSlice / sequence.MB;
else
    nSlice = sequence.nSlice;
end


%% Average all volumes

volume_segement = zeros(length(volume_event), data.sequence.TR * data.fsample);

for iVol = 1 : length(volume_event)
    volume_segement( iVol, : ) = hpf_target_channel( volume_event(iVol).sample : volume_event(iVol).sample + data.sequence.TR * data.fsample -1 );
end

mean_volume_segment = mean(volume_segement);
% mean_volume_segment = abs(mean_volume_segment); % because SV depends on the sign, intoriducing a bias
% mean_volume_segment = volume_segement(1,:);

%% Compute marker shift

sdur      = round(mean(data.sdur_v));
max_shift = round(sdur);

% Only want even number
if rem(max_shift,2)
    max_shift = max_shift+1;
end

SV = zeros(max_shift,1);
shift_vector = -max_shift/2 : +max_shift/2;
for shift = 1:length(shift_vector)
    
    signal = circshift( mean_volume_segment, shift_vector(shift) );
    
    signal_segement         = zeros(2,sdur); % Use last 2 slices , because the last one contains the volume-preparation
    signal_segement( 1, : ) = signal( 1 + (nSlice-2)*sdur : (nSlice-1)*sdur  );
    signal_segement( 2, : ) = signal( 1 + (nSlice-1)*sdur : (nSlice-0)*sdur  );
%     for iSlice = nSlice-2 : nSlice
%         signal_segement(iSlice, :) = signal( 1 + (iSlice-1)*sdur : (iSlice)*sdur  );
%     end

%     SV(shift) = sum(std(signal_segement));
%     SV(shift) = sum(abs(diff(signal_segement)));
    [~,SV(shift)]= min(std(signal_segement));
    
    % If you want to "see" the effect of sdur & dtime optimization, uncomment the lines bellow.
    % *************************************************************************
    figPtr = findall(0,'Tag',mfilename); % Is the figure already open ?
    if ~isempty(figPtr) % Figure exists so brings it to the focus
        figure(figPtr);
    else % Create the figure
        
        % Create a figure
        figure( ...
            'Name'            , mfilename                , ...
            'NumberTitle'     , 'off'                    , ...
            'Tag'             , mfilename                );
    end
    image(signal_segement,'CDataMapping','scaled'), colormap(gray(256));
% plot(std(signal_segement))
    drawnow
    % *************************************************************************
    
end

[ ~, idx_min_SV ]= min(SV);
volume_shift = -shift_vector(idx_min_SV);

fprintf('[%s]: volume & slice markers will be shifted %d samples \n',mfilename, volume_shift)

% ********
% figure
plot(SV)
% ********


signal = circshift( mean_volume_segment, shift_vector(idx_min_SV) );
% signal = signal(end-10 : end);
% signal = abs(signal);
[Y,I] = min(signal);
plot(signal)

return

%% Apply marker shift

event = data.cfg.event;

% Volume
volume_marker_idx        = strcmp({event.value}, volume_marker_name);
event(volume_marker_idx) = farm_offset_marker(event(volume_marker_idx), volume_shift);

% Slice
volume_marker_idx        = strcmp({event.value}, 's');
event(volume_marker_idx) = farm_offset_marker(event(volume_marker_idx), volume_shift);

data.cfg.event = event;


end % function
