function initial_hpf( self, hpf )
% INITIAL_HPF will take the raw data, and apply highpass filter on it.
% HPF @ 30 Hz removes the artifact due to electrode movement inside the static magnetic field B0
% This filtering step is MANDATORY for EMG, or any electrode with movements in B0
%
% SYNTAX
%       data.workflow.INITIAL_HPF( )
%       data.workflow.INITIAL_HPF( hpf )
%
% INPUTS
%       - hpf : high pass filter (Hz)
%
%
% DEFAULTS
%       - hpf : 30 Hz
%
% NOTES
%       - of hpf = [], just copy the data and skip filtering
%       - have to test/develop to check if FARM actual pipeline is feasable for EEG
%
%
%**************************************************************************
% Ref : Van der Meer, J. N., Tijssen, M. A. J., Bour, L. J., van Rootselaar, A. F., & Nederveen, A. J. (2010).
%       Robust EMG–fMRI artifact reduction for motion (FARM).
%       Clinical Neurophysiology, 121(5), 766–776.
%       https://doi.org/10.1016/j.clinph.2009.12.035


%% Checks

narginchk(1,2)

farm_check_data( self )


%% Load

[ self, skip ]= farm.io.intermediate.load(self,mfilename);
if skip, return, end


%% Parameters

if ~exist('hpf','var')
    hpf = 30; % Hz
end


%% Main

fprintf('[%s]: initial HPF... ',mfilename)

% Make a copy
self.initial_hpf = self.trial{1};

% Filter the selected channels
if ~isempty(hpf)
    self.initial_hpf(self.selected_channels_idx,:) = farm.filter(self.initial_hpf(self.selected_channels_idx,:), self.fsample, hpf);
end

fprintf('done \n')


%% Save

farm.io.intermediate.save(self,mfilename,'initial_hpf')


end % function
