classdef farm_abstract < handle
    
    properties( Hidden = true )
        
        data % @farm_data
        
    end % properties
    
    methods
        
        %------------------------------------------------------------------
        % constructor
        function self = farm_abstract( data )
            if nargin > 0
                
                self.data = data;
                
            end
        end % function
        
    end % methods
    
end % classdef
