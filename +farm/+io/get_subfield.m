function subfield_content = get_subfield( data, subfield )
% GET_SUBFIELD allows to get subfields smartly => check example bellow
%
% SYNTAX
%       subfield_content = farm.io.GET_SUBFIELD( data, subfield )
%
% INPUTS
%       - data     : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - subfield : char describing subfields, such as 'cfg.outdir.png'
%
% EXAMPLE
%       png_dir = farm.io.GET_SUBFIELD( data, 'cfg.outdir.png' )
%

if nargin==0, help(mfilename('fullpath')); return; end


%% Checks

narginchk(2,2)


%% Go

% construct subscript reference struct from dot delimited tag string
tags = textscan(subfield,'%s', 'delimiter','.');
subs = struct('type','.','subs',tags{1}');

try
    subfield_content = subsref(data, subs);
catch err %#ok<NASGU>  //  just discard silently the error
    subfield_content = [];
end


end % function
