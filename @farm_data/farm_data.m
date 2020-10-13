classdef farm_data < handle

    properties
        
        % User defined
        dirpath
        fname
        MRI_trigger_message
        channel_regex
        cfg
        
        % Derivatives
        fname_eeg
        fname_hdr
        fname_mrk
        ftdata    % fieldtrip "data", output of ft_preprocessing(cfg)
        
        sequence % @farm_sequence
        marker   % @farm_marker
        
    end % properties
    
    methods
        
        %------------------------------------------------------------------
        % constructor
        function self = farm_data(  )
            
            self.sequence = farm_sequence( self );
            self.marker   = farm_marker  ( self );
            
        end % function
        
    end % methods
    
end % classdef
