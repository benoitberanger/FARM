function farm_check_data( data )
%FARM_CHECK_DATA will check if the input 'data' is what the pipeline expects
% "data" must be ft_preprocessing output, with events stored in data.cfg.event
% 
% example : 
% 
% data = 
%   struct with fields:
% 
%            hdr: [1×1 struct]
%          label: {4×1 cell}
%           time: {[1×2656001 double]}
%          trial: {[4×2656001 double]}
%        fsample: 5000
%     sampleinfo: [2112506 4768506]
%            cfg: [1×1 struct]
% 
% >> data.cfg
% ans = 
%   struct with fields:
% 
%               dataset: '/matlab/FARM/sample_dataset/flex_ext_lr.vhdr'
%                   trl: [2112506 4768506 0]
%                   [...]
%                   [...]
%                   [...]
%                 event: [1×300 struct]
% 
% 
% See also ft_preprocessing ft_read_event ft_filter_event ft_databrowser

if nargin==0, help(mfilename); return; end


%% Required

assert( isstruct(data), '[%s]: "data" must be a structure ', mfilename)

fields = {'hdr', 'label', 'time', 'trial', 'fsample', 'sampleinfo', 'cfg'};
for f = fields
    assert( isfield(data,f), '[%s]: data have a field "%s"', f, mfilename)
end

assert( isfield(data.cfg,'event'), '[%s]: data.cfg have a field "event"', mfilename)


end % function
