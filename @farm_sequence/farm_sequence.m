classdef farm_sequence < farm_abstract
    
    properties
        
        TR     % in seconds (s)
        nSlice % integer
        MB     % multiband factor
        nVol   % integer or NaN, if [] it means use all volumes
        
    end % properties
    
    methods
        
        %------------------------------------------------------------------
        % constructor
        function self = farm_sequence( data )
            self = self@farm_abstract( data ); % use constructor from @farm_abstract
        end % function
        
    end % methods
    
    
end % classdef
