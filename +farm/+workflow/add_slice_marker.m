function data = add_slice_marker( data )
% ADD_SLICE_MARKER will generate slice markers using the volume markers
%
% SYNTAX
%         data = farm.workflow.ADD_SLICE_MARKER( data )
%
% INPUTS
%       - data : see <a href="matlab: help farm_check_data">farm_check_data</a>
%
% STRATEGY
%       For each volume marker, we have nSlice. Slice onsets are seperated
%       by sdur(v) where v is the volume index. Also, the dead time before
%       the next volume marker is writen dtime(v). Slice markers will be
%       equaly spaced at using diffrent sdur(v), and the best sdur(v) will
%       be evaluated using "cost function" called Sum of Variance (SV).
%       Optimal sdur(v) will be given when SV will be at the global
%       minimum.
%
%
%**************************************************************************
% Ref : Van der Meer, J. N., Tijssen, M. A. J., Bour, L. J., van Rootselaar, A. F., & Nederveen, A. J. (2010).
%       Robust EMG–fMRI artifact reduction for motion (FARM).
%       Clinical Neurophysiology, 121(5), 766–776.
%       https://doi.org/10.1016/j.clinph.2009.12.035
%
%       S.I. Gonçalves, P.J.W. Pouwels, J.P.A. Kuijer, R.M. Heethaar, J.C. de Munck
%       Artifact removal in co-registered EEG/fMRI by selective average subtraction
%       Clinical Neurophysiology 118 (2007) 2437–2450
%       https://doi.org/10.1016/j.clinph.2007.08.017
%
%       R.K. Niazy, C.F. Beckmann, G.D. Iannetti, J.M. Brady, and S.M. Smith
%       Removal of FMRI environment artifacts from EEG data using optimal basis sets
%       NeuroImage 28 (2005) 720 – 737
%       https://doi.org/10.1016/j.neuroimage.2005.06.067
%

if nargin==0, help(mfilename('fullpath')); return; end


%% Checks

narginchk(1,1)

farm_check_data( data )


%% Load

[ data, skip ]= farm.io.intermediate.load(data,mfilename);
if skip
    data = add_slice_marker_event(data);
    return
end


%% Remove low frequencies, including EMG, we only need the gradients to compute slice markers

hpf_target_channel = ft_preproc_highpassfilter( ...
    data.initial_hpf(data.target_channel,:)   , ...
    data.fsample                              , ...
    250                                       );


%% Prepare some paramters

% nVol
volume_event = farm.sequence.get_volume_event( data );
nVol         = farm.sequence.get_nVol        ( data );
volume_event = volume_event(1:nVol);

% nSlice
nSlice       = farm.sequence.get_nSlice      ( data );

volume_onset   = [volume_event.sample];
nSample_per_TR = median(diff(volume_onset));

% dtime is the preparation-segment duration at the end of the volume
% dtime_max is the maximum possible value
dtime_max         = round( nSample_per_TR / nSlice / 2 );
dtime_possibility = 0 : dtime_max;

% sdur is the slice-segment duration
sdur_possibility = (nSample_per_TR - dtime_possibility) / nSlice;


%% Routine : compute optimal sdur for each volume, then add slice markers

sdur_v = zeros(nVol,1);

fprintf('[%s]: Initial estimate of sdur & dtime... ', farm.io.mfilename)

for iVol = 1 : nVol
    %% Evaluate the likelihood of each sdur to be the right one
    
    volum_onset     = volume_event(iVol).sample;
    std_possibility = nan(length(sdur_possibility),1); % it's SV in the article, Sum of the Variance, equation (2)
    
    for idx_sdur = 1 : length(sdur_possibility)
        
        sdur             = sdur_possibility(idx_sdur); % current sdur
        slice_datapoints = zeros(nSlice,round(sdur));  % slice-segment for all slcies, according to the current sdur
        
        for iSlice = 1 : nSlice
            
            slice_onset                = volum_onset + round( (iSlice-1) * sdur );
            slice_datapoints(iSlice,:) = hpf_target_channel( slice_onset : slice_onset + round(sdur) - 1 );
            
        end % iSlice
        
        std_possibility(idx_sdur) = sum(std(slice_datapoints));
        
    end % sdur
    
    
    %% Get the optimal sdur
    
    [ ~, idx_optimal_sdur ] = min(std_possibility);    % optimal sdur corresponds to the minimum of SV
    sdur_v(iVol)    = sdur_possibility(idx_optimal_sdur);
    
    
end % iVol

fprintf('done \n')

fprintf('[%s]: mean(sdur_v) = %g samples \n', farm.io.mfilename, mean(sdur_v))
fprintf('[%s]: std (sdur_v) = %g samples \n', farm.io.mfilename, std (sdur_v))

data.sdur_v  = sdur_v;
data.dtime_v = nSample_per_TR - sdur_v * nSlice;

data = add_slice_marker_event(data); % local function, see below


%% Save

farm.io.intermediate.save(data,mfilename,'sdur_v','dtime_v')


end % function

%--------------------------------------------------------------------------
function data = add_slice_marker_event(data)

% nVol
volume_event = farm.sequence.get_volume_event( data );
nVol         = farm.sequence.get_nVol        ( data );
volume_event = volume_event(1:nVol);

% nSlice
nSlice       = farm.sequence.get_nSlice      ( data );

for iVol = 1 : nVol
    
    volum_onset = volume_event(iVol).sample;
    
    for iSlice = 1 : nSlice
        
        optimal_slice_onset = volum_onset + round( (iSlice-1) * data.sdur_v(iVol) );
        
        evt          = struct;
        evt.type     = 'Response';
        evt.value    = 's';
        evt.sample   = optimal_slice_onset;
        evt.duration = 1;
        evt.timestamp= '';
        evt.offset   = [];
        
        data.cfg.event(end+1) = evt;
        
    end % iSlice
    
end % iVol

end % function
