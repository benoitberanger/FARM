function load_eeg_vhdr_vmrk( self )
% self : @farm_data

assert( exist(self.dirpath,'dir')==7, '[%s]: dir invalid : %s', mfilename, self.dirpath )

self.fname_eeg = fullfile(self.dirpath, [self.fname '.eeg' ]);
self.fname_hdr = fullfile(self.dirpath, [self.fname '.vhdr']);
self.fname_mrk = fullfile(self.dirpath, [self.fname '.vmrk']);

% Load numerical data
cfg           = [];
cfg.dataset   = self.fname_hdr;
self.ftdata   = ft_preprocessing(cfg); % load data

% Load header & events
self.ftdata.cfg.event  = ft_read_event(self.fname_mrk);
self.marker.volume_marker_name = 'V';                                                      % name of the volume event in data.cfg.event
self.marker.change_value(...
    self.marker.MRI_trigger_message , ...
    self.marker.volume_marker_name    ...
    ); % rename volume marker, just for comfort


end % function
