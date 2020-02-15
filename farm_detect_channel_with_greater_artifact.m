function data = farm_detect_channel_with_greater_artifact( data )
% FARM_DETECT_CHANNEL_WITH_GREATER_ARTIFACT will detect which channel has the biggest artifact,
% and store the channel index for latter use.
%
% SYNTAX
%       data = FARM_DETECT_CHANNEL_WITH_GREATER_ARTIFACT( data )
%
% INPUTS
%       - data : see <a href="matlab: help farm_check_data">farm_check_data</a>
%
% See also farm_select_channel

if nargin==0, help(mfilename('fullpath')); return; end


%% Check

assert( isfield(data,'selected_channels_idx') , '[%s]: First, select channels with farm_select_channel', mfilename )


%% Main

max_all_channels = max( abs(data.initial_hpf(data.selected_channels_idx,:)), [], 2 );
[ ~, target_channel ] = max(max_all_channels); % index of the channel we use to perform all computations related to sdur & dtime

data.target_channel = target_channel; % save this channel index, we will use latter


end % function
