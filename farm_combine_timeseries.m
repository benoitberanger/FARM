function comb = farm_combine_timeseries( timeseries, combine_method )
% FARM_COMBINE_TIMESERIES
%
% SYNTAX
%       combined = FARM_COMBINE_TIMESERIES( timeseries )                 % use default method (mean)
%       combined = FARM_COMBINE_TIMESERIES( timeseries, combine_method ) % use choosen method
%
% INPUTS
%       - timeseries     : see <a href="matlab: help farm_get_timeseries">farm_get_timeseries</a>
%       - combine_method : can be mean(default), pca
%


if nargin==0, help(mfilename('fullpath')); return; end


%% Check

narginchk(1,2)

if ~exist('combine_method','var')
    combine_method = 'mean';
end


%% Main

switch combine_method
    case 'mean'
        comb = mean(timeseries);
    case 'pca'
        timeseries = timeseries';
        timeseries = timeseries - mean(timeseries);
        [~, Eload, ~] = farm.pca_calc(timeseries);
        comb = Eload(:,1); % take first component
        comb = comb';
    case []
        assert(size(timeseries,1)==1, 'several channels => need to specify the combine_method')
        comb = datapoints;
    otherwise
        error('unrecognized combine_method')
end


end % function
