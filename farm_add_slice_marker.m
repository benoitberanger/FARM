function data = farm_add_slice_marker( data, sequence, marker_name )
% FARM_ADD_SLICE_MARKERS will generate slice markers using the volume markers
% 
% Strategy : For each volume marker, we have nSlice. Slice onsets are
% seperated by sdur(v) where v is the volume index. Also, the dead time
% before the next volume marker is writen dtime(v).
% Slice markers will be equaly spaced at using diffrent sdur(v), and the
% best sdur(v) will be evaluated using "cost function" called Sum of
% Variance (SV). Optimal sdur(v) will be given when SV will be at the
% global minimum.
%
% Ref : Van der Meer, J. N., Tijssen, M. A. J., Bour, L. J., van Rootselaar, A. F., & Nederveen, A. J. (2010).
%       Robust EMG–fMRI artifact reduction for motion (FARM).
%       Clinical Neurophysiology, 121(5), 766–776.
%       https://doi.org/10.1016/j.clinph.2009.12.035
%

if nargin==0, help(mfilename); return; end


%% Check input arguments

narginchk(3,3)

% data
farm_check_data( data )

% sequence
farm_check_sequence( sequence )

% marker_name
assert( ischar(marker_name), '[%s]: marker_name must be a char ', mfilename )


%% Detect the channel with higher "amplitude"

max_all_channels = max( abs(data.trial{1}), [], 2 );
[ ~, target_channel ] = max(max_all_channels);
hpf_target_channel = ft_preproc_highpassfilter(...
    data.trial{1}(target_channel,:), ...
    data.fsample                   , ...
    100                            ); % remove low frequencies, we only need the gradients to compute slice markers


%% Prepare some paramters

% nVol
volume_event = ft_filter_event(data.cfg.event,'value',marker_name);
assert( numel(volume_event)>0 , '%s is not a valid marker', marker_name )
if isfield(sequence,'nVol') && ~isnan(sequence.nVol)
    nVol = sequence.nVol;
    volume_event = volume_event(1:nVol);
else
    nVol = length(volume_event);
end

% nSlice
if isfield(sequence,'MB')
    nSlice = sequence.nSlice / sequence.MB;
else
    nSlice = sequence.nSlice;
end

volume_onset   = [volume_event.sample];
nSample_per_TR = volume_onset(2) - volume_onset(1);

% dtime is the preparation-segment duration at the end of the volume
% dtime_max is the maximum possible value
dtime_max         = round( nSample_per_TR / nSlice / 2 );
dtime_possibility = 0 : dtime_max;

% sdur is the slice-segement duration
sdur_possibility = (nSample_per_TR - dtime_possibility) / nSlice;
sdur_possibility = unique(round(sdur_possibility));               % keep only integer numbers, sdur is a number a datapoints


%% Routine : compute optimal sdur for each volume, then add slice markers

for iVol = 1 : nVol
    %% Evaluate the likelihood of each sdur to be the right one
    
    volum_onset     = volume_event(iVol).sample;
    std_possibility = nan(length(sdur_possibility),1); % it's SV in the article, Sum of the Variance, equation (2)
    
    for idx_sdur = 1 : length(sdur_possibility)
        
        sdur             = sdur_possibility(idx_sdur); % current sdur
        slice_datapoints = zeros(nSlice,sdur);         % slice-segement for all slcies, according to the current sdur
        
        for iSlice = 1 : nSlice
            
            slice_onset                = volum_onset + (iSlice-1) * sdur;
            slice_datapoints(iSlice,:) = hpf_target_channel( slice_onset : slice_onset + sdur - 1 );
            
        end % iSlice
        
        std_possibility(idx_sdur) = sum(std(slice_datapoints));
        
    end % sdur
    
    
    %% Get the optimal sdur
    
    [ ~, idx_optimal_sdur ] = min(std_possibility);    % optimal sdur corresponds to the minimum of SV
    optimal_sdur = sdur_possibility(idx_optimal_sdur);
    
    fprintf('[%s]: optimal sdur = %d samples @ volume %d \n', mfilename, optimal_sdur, iVol)
    
    
    %% Add slice markers
    
    for iSlice = 1 : nSlice
        
        optimal_slice_onset = volum_onset + (iSlice-1) * optimal_sdur;
        
        evt          = struct;
        evt.type     = 'Response';
        evt.value    = 's';
        evt.sample   = optimal_slice_onset;
        evt.duration = 1;
        evt.offset   = [];
        
        data.cfg.event(end+1) = evt;
        
    end
    
    
end % iVol


end % function