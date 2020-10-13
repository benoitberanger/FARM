function change_value( self, old_maker_value, new_maker_value )
% CHANGE_VALUE will replace in 'self.ftdata.cfg.event' the 'old_maker_value' with the 'new_maker_value'
%
% SYNTAX
%       data.marker.CHANGE_VALUE( old_maker_value, new_maker_value )
%
% INPUTS
%       - old_maker_value : event.value = number or string
%       - new_maker_value : event.value = number or string
%


%% Main

event = self.data.ftdata.cfg.event;

for evt = 1 : length(event)
    if strcmp(event(evt).value, old_maker_value)
        event(evt).value = new_maker_value;
    end
end

self.data.ftdata.cfg.event = event;


end % function
