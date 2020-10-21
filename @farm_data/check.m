function check( self )
% @farm_data.CHECK will check if the input 'data' is what the pipeline expects
%
% example :
%
% >> data
% data = 
%   farm_data with properties:
% 
%                 dirpath: '/matlab/FARM/sample_dataset'
%                   fname: 'me3mb3_tr1600_sl54'
%     channel_description: 'EXT|FLE'
%                     cfg: [1×1 struct]
%               fname_eeg: '/matlab/FARM/sample_dataset/me3mb3_tr1600_sl54.eeg'
%               fname_hdr: '/matlab/FARM/sample_dataset/me3mb3_tr1600_sl54.vhdr'
%               fname_mrk: '/matlab/FARM/sample_dataset/me3mb3_tr1600_sl54.vmrk'
%                  ftdata: [1×1 struct]
%                sequence: [1×1 farm_sequence]
%                  marker: [1×1 farm_marker]
%                workflow: [1×1 farm_workflow]
%
% >> data.ftdata
% ans =
%   struct with fields:
%
%            hdr: [1×1 struct]
%          label: {4×1 cell}
%           time: {[1×4833100 double]}
%          trial: {[4×4833100 double]}
%        fsample: 5000
%     sampleinfo: [1 4833100]
%            cfg: [1×1 struct]
%
%
% >> data.sequence
% ans =
%   farm_sequence with properties:
%
%         TR: 1.6
%     nSlice: 54
%         MB: 3
%       nVol: []
%
%
% >> data.marker
% ans =
%   farm_marker with properties:
%
%     MRI_trigger_message: 'R128'
%      volume_marker_name: 'V'
%
%


%% Basics

% Input
assert( ...
    isstruct(self.ftdata)              & ...
    numel   (self.ftdata)==1           & ...
    ~isempty(fieldnames(self.ftdata))   ,...
    '[%s]: "data" must be a non-empty (1x1) structure with fields, see <a href="matlab: help farm_check_data">help farm_check_data</a>', mfilename)

% Basic fields in fieldtrip data structure
fields = {'hdr', 'label', 'time', 'trial', 'fsample', 'sampleinfo', 'cfg'};
for f = fields
    assert( isfield(self.ftdata,char(f)), '[%s]: data must have a field "%s", see <a href="matlab: help farm_check_data">help farm_check_data</a>', char(f), mfilename)
end


%% Events

assert( isfield(self.ftdata.cfg,'event'), '[%s]: data.cfg must have a field "event", see <a href="matlab: help farm_check_data">help farm_check_data</a>', mfilename)


%% Sequence

sequence = self.sequence; % shortcut, for code reading.

% TR
TR = sequence.TR;
assert( ...
    isscalar (TR) &...
    TR == abs(TR) ,...
    '[%s]: data.sequence.TR must be positive scalar'                         , mfilename)

% nSlice
nSlice = sequence.nSlice;
assert( ...
    isscalar       (nSlice) &...
    nSlice == abs  (nSlice) &...
    nSlice == round(nSlice) ,...
    '[%s]: data.sequence.nSlice must be positive integer nSlice'             , mfilename)

% MB
MB = sequence.MB;
assert( ...
    isscalar   (MB) &...
    MB == abs  (MB) &...
    MB == round(MB) ,...
    '[%s]: data.sequence.MB must be positive integer MB'                     , mfilename)

% nVol
nVol = sequence.nVol;
if ~isempty(nVol)
    assert( ...
        isscalar(nVol)    &...
        nVol==abs(nVol)   &...
        nVol==round(nVol) ,...
        '[%s]: data.sequence.nVol must be positive integer nVol, or empty []', mfilename)
end


%% marker

marker = self.marker; % shortcut, for code reading.

MRI_trigger_message = marker.MRI_trigger_message;
assert( ...
    ischar(MRI_trigger_message) ,...
    '[%s]: data.marker.MRI_trigger_message must be char', mfilename)

volume_marker_name = marker.volume_marker_name;
assert( ...
    ischar(volume_marker_name) ,...
    '[%s]: data.marker.volume_marker_name must be char' , mfilename)


end % function
