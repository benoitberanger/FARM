function data = farm_pick_slice_for_template( data, WindowLength )
% FARM_PICK_SLICE_FOR_TEMPLATE will prepare the slice index used for the
% later slice artifact correction using slice-templates
%
% Strategy : for a given slice marker, the slices used for the compuation
% of the template will follow the following rules :
% - cannot pick yourself : it means slice(i) won't be used for template(i)
% - cannot pick the first slice of a volume : too close from volume artifact
% - cannot pick the last  slice of a volume : too close from volume artifact
% - must   pick slices from your surroundings
% - must   pick exactly N = WindowLength slices
%
% default WindowLength is 50
%
% Ref : Van der Meer, J. N., Tijssen, M. A. J., Bour, L. J., van Rootselaar, A. F., & Nederveen, A. J. (2010).
%       Robust EMG–fMRI artifact reduction for motion (FARM).
%       Clinical Neurophysiology, 121(5), 766–776.
%       https://doi.org/10.1016/j.clinph.2009.12.035
%

if nargin==0, help(mfilename); return; end


%% Parameters

if nargin < 2
    WindowLength = 50;
end
assert( round(WindowLength)==WindowLength & WindowLength>0, 'WindowLength must be positive integer' )


%% Preparations

slice_event  = ft_filter_event( data.cfg.event, 'value', 's' );

nMarker = length(slice_event);
% nSlice
if isfield(data.sequence,'MB')
    nSlice = data.sequence.nSlice / data.sequence.MB;
else
    nSlice = data.sequence.nSlice;
end

marker_vector = 1 : nMarker;


%% Forbidden slices

islastslice  = rem(marker_vector, nSlice) == 0;
isfirstslice = circshift(islastslice, +1);

forbidden_slice = islastslice | isfirstslice;

% WARNING : we still need to follow the rule 'cannot pick yourself'


%% Good slices

good_slice      = ~forbidden_slice;
good_slice_idx  = find(good_slice);

% WARNING : we still need to follow the rule 'cannot pick yourself'


%% For each good slice, pick the surrounding

fprintf('[%s]: Preparing slices available as template for the slice-correction... ', mfilename)

slice_idx_for_template = nan( nMarker, WindowLength );

% It's a bit trick here when iSlice < WindowLength.
% That's why I have this procedure that looks weird
for iSlice = 1 : nMarker
    good_slice_idx_notSelf           = good_slice_idx(good_slice_idx ~= iSlice);                   % not self
    distance_to_slice                = abs( good_slice_idx_notSelf - iSlice );
    [~,distance_to_slice_sorted_idx] = sort(distance_to_slice);                                    % sort the distance, keep index. WARNING : here we work with index of sorted ditances
    slice_in_window_sorted_idx       = distance_to_slice_sorted_idx(1:WindowLength);               % and pick N=WindowLength, also a rule.
    slice_in_window                  = sort( good_slice_idx_notSelf(slice_in_window_sorted_idx) ); % get the corresponding slice index (not anymore sorted distance slice index)
    slice_idx_for_template(iSlice,:) = slice_in_window;
end


%% Save useful info

data. slice_info                         = struct;
data. slice_info. marker_vector          = marker_vector;

data. slice_info. islastslice            = islastslice;
data. slice_info. isfirstslice           = isfirstslice;

data. slice_info.  lastslice_idx         = marker_vector(islastslice );
data. slice_info. firstslice_idx         = marker_vector(isfirstslice);

data. slice_info. good_slice             = good_slice;
data. slice_info. good_slice_idx         = good_slice_idx;

data. slice_info. slice_idx_for_template = slice_idx_for_template;

fprintf('done \n')


end % function
