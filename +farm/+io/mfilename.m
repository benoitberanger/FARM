function str = mfilename( )
% farm.io.MFILENAME behaves like the built-in "mfilename" but also with packages (+packege/+subpackage/fcn.m)
% NOTE : This function is tuned for FARM functions


%% Main

db = dbstack('-completenames');

% check
if numel(db) < 2
    warning('farm.io.mfilename is intended to be used within a FARM function')
    str = '';
    return
end

target = db(2).file;
str = target(1:end-2); % remove ".m"
str = strrep(str, farm_rootdir, '');
str = str(2:end); % remove first filesep
str = strrep(str, '+', '');
str = strrep(str, filesep, '.');


end % function
