function reginfo = farm_emg_regressor( data, timeseries, name, comb_method )
% FARM_EMG_REGRESSOR is a wrapper, performing :
% 1) EMG envelope : Hilbter transform, using <a href="matlab: help ft_preproc_hilbert">ft_preproc_hilbert</a>
% 1.5) combine if necessary
% 2) Downsample @ 500Hz for faster convolution
% 3) Convolve with HRF using SPM toolbox, and compute the first derivative
% 4) Downsample the convonved signal @ TR
%
%
% SYNTAX
%       reginfo = FARM_EMG_REGRESSOR( data, timeseries, name )
%       reginfo = FARM_EMG_REGRESSOR( data, timeseries, name, combine_method )
%
% INPUT
%       - data           : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - timeseries     : see <a href="matlab: help farm_get_timeseries">farm_get_timeseries</a>
%       - name           : name of the regressor, it will be used for the output file name, and in SPM regressor name
%       - combine_method : (optional) see <a href="matlab: help farm_combine_timeseries">farm_combine_timeseries</a>
%
% See also farm_get_timeseries farm_plot_regressor farm_combine_timeseries farm_emg_envelope farm.resample farm_make_regressor

if nargin==0, help(mfilename('fullpath')); return; end


%% Checks

narginchk(3,4)

if ~exist('comb_method','var')
    comb_method = 'mean';
end


%% Main

% Get envelope
envelope = farm_emg_envelope( timeseries, data.fsample, 8 );

% Combine if necessary
if size( timeseries, 1 ) > 1
    comb = farm_combine_timeseries( envelope, comb_method );
else
    comb = envelope;
end

% Downsample for faster convolution
time           = (0:length(comb)-1)/data.fsample;
new_fsample    = 1000; % Hz
new_timeseries = farm.resample( comb, time, data.fsample, new_fsample/data.fsample );

% Make regressor
reginfo = farm_make_regressor( new_timeseries, new_fsample, data.sequence.TR );

% Save name in reginfo
reginfo.name = name;

% (this is for the plot)
reginfo.raw      = abs(farm.normalize_range(timeseries));
reginfo.time_raw = (0:length(timeseries)-1)/data.fsample;


end % function
