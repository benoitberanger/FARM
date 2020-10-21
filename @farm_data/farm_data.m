classdef farm_data < handle

    properties
        
        % User defined
        dirpath       % char
        fname         % char
        channel_description % char or cellstr (for regex usage) OR scalar OR vector (for direct indexing)
        cfg           % struct
        
        % Derivatives
        fname_eeg     % char
        fname_hdr     % char
        fname_mrk     % char
        ftdata        % fieldtrip "data", output of ft_preprocessing(cfg)
        
        sequence      % @farm_sequence
        marker        % @farm_marker
        workflow      % @farm_workflow
        
    end % properties
    
    methods
        
        %------------------------------------------------------------------
        % constructor
        function self = farm_data(  )
            
            self.sequence = farm_sequence( self );
            self.marker   = farm_marker  ( self );
            self.workflow = farm_workflow( self );
            
        end % function
        
    end % methods
    
end % classdef
