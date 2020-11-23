function farm_check_data( data )
% FARM_CHECK_DATA will check if the input 'data' is what the pipeline expects
%
%   "data" must be ft_preprocessing output, with :
%       - events              stored in data.cfg.event
%       - sequence parameters stored in data.sequence
%       - volume marker name  stored in data.volume_marker_name
%
% example :
%
% >> data
% ans =
%   struct with fields:
%
%                    hdr: [1×1 struct]
%                  label: {4×1 cell}
%                   time: {[1×4278500 double]}
%                  trial: {[4×4278500 double]}
%                fsample: 5000
%             sampleinfo: [1 4278500]
%                    cfg: [1×1 struct]
%               sequence: [1×1 struct]
%     volume_marker_name: 'V'
%
% >> data.cfg
% ans =
%   struct with fields:
%
%               dataset: '/matlab/FARM/sample_dataset/mb6_tr1000_sl72.vhdr'
%               channel: {4×1 cell}
%                   [...]
%                   [...]
%                   [...]
%                 event: [1×1036 struct]
%
%
% >> data.sequence
% ans =
%   struct with fields:
%
%         TR: 1
%     nSlice: 72
%         MB: 6
%       nVol: []
%
% See also ft_preprocessing ft_read_event ft_filter_event ft_databrowser

if nargin==0, help(mfilename('fullpath')); return; end


%% Basics

% Input
assert( ...
    isstruct(data)              & ...
    numel   (data)==1           & ...
    ~isempty(fieldnames(data))   ,...
    '[%s]: "data" must be a non-empty (1x1) structure with fields, see <a href="matlab: help farm_check_data">help farm_check_data</a>', mfilename)

% Basic fields in fieldtrip data structure
fields = {'hdr', 'label', 'time', 'trial', 'fsample', 'sampleinfo', 'cfg'};
for f = fields
    assert( isfield(data,char(f)), '[%s]: data must have a field "%s", see <a href="matlab: help farm_check_data">help farm_check_data</a>', char(f), mfilename)
end


%% Events

assert( isfield(data.cfg,'event'), '[%s]: data.cfg must have a field "event", see <a href="matlab: help farm_check_data">help farm_check_data</a>', mfilename)
volume_event = farm.sequence.get_volume_event( data );
assert( numel(volume_event)>0, '[%s]: data.cfg.event does not have volume event, see <a href="matlab: help farm_check_data">help farm_check_data</a>', mfilename)


%% Sequence

% data.sequence        = struct;
% data.sequence.TR     = 1.000; % in seconds
% data.sequence.nSlice = 72;
% data.sequence.MB     = 6;     % multiband factor
% data.sequence.nTR    = [];    % integer or []

assert( isfield(data,'sequence'),    '[%s]: data must have a field "sequence"'                       , mfilename)
sequence = data.sequence; % shortcut, for code reading.

assert( isstruct(sequence),          '[%s]: "sequence" must be a structure '                         , mfilename)

% TR
assert( isfield(sequence,'TR'),      '[%s]: sequence have a field "TR"'                              , mfilename); TR     = sequence.TR;
assert( ...
    isscalar (TR) &...
    TR == abs(TR) ,                  '[%s]: sequence.TR must be positive scalar'                     , mfilename)

% nSlice
assert( isfield(sequence,'nSlice') , '[%s]: sequence have a field "nSlice"'                          , mfilename); nSlice = sequence.nSlice;
assert( ...
    isscalar       (nSlice) &...
    nSlice == abs  (nSlice) &...
    nSlice == round(nSlice) ,        '[%s]: sequence.nSlice must be positive integer nSlice'         , mfilename)

% MB
if isfield(sequence, 'MB')
    
    MB = sequence.MB;
    
    assert( ...
        isscalar   (MB) &...
        MB == abs  (MB) &...
        MB == round(MB)  ,           '[%s]: sequence.MB must be positive integer MB'                 , mfilename)
    
end

% nVol
if isfield(sequence, 'nVol')
    
    nVol = sequence.nVol;
    
    if ~isempty(nVol)
        assert( ...
            isscalar(nVol)    &...
            nVol==abs(nVol)   &...
            nVol==round(nVol),       '[%s]: sequence.nVol must be positive integer nVol, or empty []', mfilename)
    end
    
end


end % function
