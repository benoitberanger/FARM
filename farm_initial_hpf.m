function data = farm_initial_hpf( data, hpf )
% FARM_INITIAL_HPF will take the raw data, and apply highpass filter on it.
% HPF @ 30 Hz removes the artifact due to electrode movement inside the static magnetic field B0
% This filtering step is MANDATORY for EMG, or any electrode with movements in B0
%
% SYNTAX
%       data = FARM_INITIAL_HPF( data, hpf )
%
% INPUTS
%       - data         : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - hpf          : high pass filter (Hz)
%
%
% DEFAULTS
%       - hpf : 30 Hz
%
% NOTES
%       - have to test/develop to check if FARM actual pipeline is feasable for EEG
%
%
%**************************************************************************
% Ref : Van der Meer, J. N., Tijssen, M. A. J., Bour, L. J., van Rootselaar, A. F., & Nederveen, A. J. (2010).
%       Robust EMG–fMRI artifact reduction for motion (FARM).
%       Clinical Neurophysiology, 121(5), 766–776.
%       https://doi.org/10.1016/j.clinph.2009.12.035

if nargin==0, help(mfilename('fullpath')); return; end


%% Checks

narginchk(1,2)

farm_check_data( data )

if ~exist('hpf','var')
    hpf = 30; % Hz
end


%% Main

% Make a copy
data.initial_hpf = data.trial{1};

% Filter the selected channels
data.initial_hpf(data.selected_channels_idx,:) = farm.filter(data.initial_hpf(data.selected_channels_idx,:), data.fsample, hpf);


end % function
