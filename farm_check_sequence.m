function farm_check_sequence( sequence )
%FARM_CHECK_SEQUENCE will check if the input 'sequence' is what the pipeline expects
% "sequence" must be a structure such as :
%
% sequence        = struct;
% sequence.TR     = 1.6; % in seconds
% sequence.nSlice = 54;
%
% % optional parameters are :
% sequence.MB     = 3;   % multiband factor
% sequence.nTR    = 300; % integer or NaN

if nargin==0, help(mfilename); return; end


%% Required

assert( isstruct(sequence),          '[%s]: "sequence" must be a structure '                 , mfilename)

% TR
assert( isfield(sequence,'TR'),      '[%s]: sequence have a field "TR"'                      , mfilename); TR     = sequence.TR;
assert( isscalar(TR) &...
    TR==abs(TR) ,                    '[%s]: sequence.TR must be positive scalar'             , mfilename)

% nSlice
assert( isfield(sequence,'nSlice') , '[%s]: sequence have a field "nSlice"'                  , mfilename); nSlice = sequence.nSlice;
assert( ...
    isscalar(nSlice)      &...
    nSlice==abs(nSlice)   &...
    nSlice==round(nSlice),           '[%s]: sequence.nSlice must be positive integer nSlice' , mfilename)


%% Optional

if isfield(sequence, 'MB')
    
    MB = sequence.MB;
    
    assert( ...
        isscalar(MB)  &...
        MB==abs(MB)   &...
        MB==round(MB), '[%s]: sequence.MB must be positive integer MB', mfilename)
    
end


if isfield(sequence, 'nVol')
    
    nVol = sequence.nVol;
    
    if ~isnan(nVol)
        assert( ...
            isscalar(nVol)  &...
            nVol==abs(nVol)   &...
            nVol==round(nVol), '[%s]: sequence.nVol must be positive integer nVol', mfilename)
    end
    
end


end % function
