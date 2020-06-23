function save( data, calling_function, varargin )
%
% EXAMPLE
%       farm.io.intermediate.SAVE( data, 'farm_optimize_slice_template_using_PCA', 'sub_template','pca_clean','pca_noise' )
%
% FLAG
%       - data.cfg.intermediate_results_save
%       - data.cfg.intermediate_results_overwrite
%
% INPUT
%       - data             : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - calling_function : name of the farm_* function calling
%       - varargin         : list of fields to save

if nargin==0, help(mfilename('fullpath')); return; end


%% Checks

narginchk(3,Inf)


%% Main

if data.cfg.intermediate_results_save
    
    fname = farm.io.intermediate.get_fname( data, calling_function );
    
    if ~exist(fname,'file') || data.cfg.intermediate_results_overwrite
        
        % What to save ?
        to_save = struct;
        for v = 1 : length(varargin)
            to_save.(varargin{v}) = data.(varargin{v});
        end
        
        % Save the fields of a structure as individual variables
        outdir = fileparts(fname);
        if ~exist( outdir, 'dir' )==7, mkdir(outdir); end
        save(fname, '-struct', 'to_save')
        fprintf('[farm.io.intermediate.save]: saved %s \n', fname )
        
    end
    
end


end % function
