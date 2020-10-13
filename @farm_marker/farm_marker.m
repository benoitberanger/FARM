classdef farm_marker < farm_abstract

    properties
        
        MRI_trigger_message % char
        volume_marker_name  % char
        
    end % properties
    
    methods
        
        %------------------------------------------------------------------
        % constructor
        function self = farm_marker( data )
            self = self@farm_abstract( data ); % use constructor from @farm_abstract
        end % function
        
    end % methods
    
end % classdef
