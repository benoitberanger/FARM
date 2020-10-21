classdef farm_workflow < farm_abstract
    
    properties
        selected_channels_idx
        selected_channels_name
    end % properties
    
    methods
        
        %------------------------------------------------------------------
        % constructor
        function self = farm_workflow( data )
            self = self@farm_abstract( data ); % use constructor from @farm_abstract
        end % function
        
    end % methods
    
end % classdef
