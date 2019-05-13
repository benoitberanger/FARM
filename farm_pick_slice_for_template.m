function data = farm_pick_slice_for_template( data )
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

WindowLength = 50;

if nargin==0, help(mfilename); return; end


%% Preparations

slice_event  = ft_filter_event( data.cfg.event, 'value', 's' );

nMarker = length(slice_event);
nSlice  = data.sequence.nSlice;

marker_vector = 1 : nMarker;


%% Forbidden slices

islastslice  = rem(marker_vector, nSlice) == 0;
isvolume     = circshift(islastslice, +1);
isfirstslice = circshift(isvolume   , +1);

forbidden_slice = islastslice | isvolume | isfirstslice;

% WARNING : we still need to follow the rule 'cannot pick yourself'


%% Good slices

good_slice      = ~forbidden_slice;
good_slice_idx  = find(good_slice);

% WARNING : we still need to follow the rule 'cannot pick yourself'


%% For each good slice, pick the surrounding

fprintf('[%s]: Preparing slices available as template for the slice-correction... ', mfilename)

slice_idx_for_template = nan( length(good_slice_idx), WindowLength );

for iSlice = 1 : length(good_slice_idx)
    
    distance_to_slice                = abs( good_slice_idx - good_slice_idx(iSlice) );
    [~,slice_sorted]                 = sort(distance_to_slice);
    slice_in_window_sorted_idx       = slice_sorted(2:WindowLength+1);
    slice_in_window                  = sort( good_slice_idx(slice_in_window_sorted_idx) );
    slice_idx_for_template(iSlice,:) = slice_in_window;
    
end


%% Save useful info

data.slice_info                        = struct;
data.slice_info.marker_vector          = marker_vector;
data.slice_info.islastslice            = islastslice;
data.slice_info.isvolume               = isvolume;
data.slice_info.isfirstslice           = isfirstslice;
data.slice_info.lastslice_idx          = marker_vector(islastslice);
data.slice_info.volume_idx             = marker_vector(isvolume);
data.slice_info.firstslice_idx         = marker_vector(isfirstslice);
data.slice_info.good_slice             = good_slice;
data.slice_info.good_slice_idx         = good_slice_idx;
data.slice_info.slice_idx_for_template = slice_idx_for_template;

fprintf('done \n')


end % function
