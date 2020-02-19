function reginfo = farm_acc_regressor( data, timeseries, comb_method )
% FARM_ACC_REGRESSOR is a wrapper, performing :
%
%
% SYNTAX
%       reginfo = FARM_ACC_REGRESSOR( data, timeseries )
%       reginfo = FARM_ACC_REGRESSOR( data, timeseries, combine_method )
%
% INPUT
%       - data           : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - timeseries     : see <a href="matlab: help farm_get_timeseries">farm_get_timeseries</a>
%       - combine_method : (optional) see <a href="matlab: help farm_combine_timeseries">farm_combine_timeseries</a>
%
% See also farm_get_timeseries farm_plot_regressor farm_combine_timeseries farm.resample farm_make_regressor

if nargin==0, help(mfilename('fullpath')); return; end


%% Checks

narginchk(2,3)

if ~exist('comb_method','var')
    comb_method = 'mean';
end


%% Main

% Combine if necessary
if size( timeseries, 1 ) > 1
    comb = farm_combine_timeseries( timeseries, comb_method );
else
    comb = timeseries;
end

% Downsample for faster convolution
time           = (0:length(comb)-1)/data.fsample;
new_fsample    = 500; % Hz
new_timeseries = farm.resample( comb, time, data.fsample, new_fsample/data.fsample );

% Absolute value
new_timeseries = abs(new_timeseries);

% Make regressor
reginfo = farm_make_regressor( new_timeseries, new_fsample, data.sequence.TR );


end % function