function farm_add_slice_markers( data, sequence )
%FARM_ADD_SLICE_MARKERS


if nargin==0, help(mfilename); return; end


%% Check input arguments

% data
farm_check_data( data )

% sequence
assert( nargin==2 , '[%s]: second input "sequence" is required ', mfilename )
farm_check_sequence( sequence )


end % function
