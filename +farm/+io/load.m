function [ data , skip ] = load( data, calling_function )
%
% EXAMPLE
%       farm.io.LOAD( data, 'farm_optimize_slice_template_using_PCA' )
%
% FLAG
%       - data.cfg.intermediate_results_overwrite
%       - data.cfg.intermediate_results_load
%
% INPUT
%       - data             : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - calling_function : name of the farm_* function calling

if nargin==0, help(mfilename('fullpath')); return; end

%% Checks

narginchk(2,2)


%% Main

skip = false;

fname = farm.io.get_fname( data, calling_function );

if data.cfg.intermediate_results_load && ~data.cfg.intermediate_results_overwrite % don't need to load file if we overwrite anyway
    
    if exist(fname,'file')
        
        content = load(fname);
        
        % Add loaded content into data
        fields = fieldnames(content);
        for f = 1 : length(fields)
            data.(fields{f}) = content.(fields{f});
        end
        fprintf('[farm.io.load]: load %s \n', fname )
        
        skip = true;
        
    end
    
end


end % function
