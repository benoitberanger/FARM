function varargout = farm_plot_TFA( data, TFA )
% FARM_PLOT_TFA will plot the result of the farm_time_frequency_analysis_emg_acc
%
% SYNTAX
%              FARM_PLOT_TFA( data, TFA )
%       figH = FARM_PLOT_TFA( data, TFA )
%
% INPUTS
%       - data : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - TFA  : output of <a href="matlab: help farm_time_frequency_analysis_emg_acc">farm_time_frequency_analysis_emg_acc</a>
%
% NOTES
%
%
% See also farm_time_frequency_analysis_emg_acc

if nargin==0, help(mfilename('fullpath')); return; end


%% Figure proportions

x_vect = [1 5 1 30 1];
y_vect = [1 7 1 10 1];

x_vect = x_vect / sum(x_vect);
y_vect = y_vect / sum(y_vect);

pos_powspctrm = [ sum(x_vect(1:3))  sum(y_vect(1:3))  x_vect(4)  y_vect(4) ];
pos_Fmean     = [ sum(x_vect(1:3))      y_vect(1)     x_vect(4)  y_vect(2) ];
pos_Tmean     = [     x_vect(1)     sum(y_vect(1:3))  x_vect(2)  y_vect(4) ];


%% Plot

% Prepare figure & tabgroup
figH = figure('Name',data.cfg.datafile,'NumberTitle','off');
figH.UserData = mfilename;
tg = uitabgroup(figH);

% Plot average spectrum
%----------------------

t = uitab(tg,'Title','avg across channels');
axes(t);

% powerspectrum(time,ferquency)
ax_3d(1) = subplot('Position',pos_powspctrm);
surf( ax_3d(1),...
    'XData', TFA.time,...
    'YData', TFA.freq,...
    'ZData', TFA.powspctrm_avg,...
    'EdgeColor', 'none')
view( ax_3d(1) , 2 )
title_str = sprintf('average powerspectrum @ {%s}', sprintf('%s,',TFA.label{:}));
title(title_str,'Interpreter','None')

% Fmean(powerspectrum)
ax_Fmean(1) = subplot('Position',pos_Fmean);
hold on
plot(TFA.time, TFA.power_Fmean_avg, 'Color','black','LineWidth',2.0 )
plot(TFA.time, TFA.peakpower_avg  , 'Color','blue' ,'LineWidth',0.5 )
l = legend('mean(power)','power@peakfreq');
l.Interpreter = 'None';
xlabel('Time (s)')
ylabel('Power')
axis tight

% Tmean(powerspectrum)
ax_Tmean(1) = subplot('Position',pos_Tmean);
plot(TFA.freq, TFA.power_Tmean_avg, 'Color','black','LineWidth',1 )
xlabel('Frequency (Hz)')
ylabel('Power')
axis tight
view([-90 90])


% Plot all channels
%------------------
for chan = 1 : length(TFA.label)
    tab_name = sprintf('channel %d / %s', TFA.info.channel_idx(chan), TFA.label{chan});
    t = uitab(tg,'Title',tab_name);
    axes(t); %#ok<*LAXES>
    
    % 3D plot
    ax_3d(chan+1) = subplot('Position',pos_powspctrm); %#ok<*AGROW>
    surf( ax_3d(chan+1),...
        'XData', TFA.time,...
        'YData', TFA.freq,...
        'ZData', squeeze(  TFA.powspctrm(chan,:,:) ),...
        'EdgeColor', 'none')
    view( ax_3d(chan+1) , 2 )
    xlabel('time (s)')
    ylabel('Frequency (Hz)')
    title_str = sprintf('powerspectrum @ %s', TFA.label{chan});
    title(title_str,'Interpreter','None');
    
    % Fmean(powerspectrum)
    ax_Fmean(chan+1) = subplot('Position',pos_Fmean);
    hold on
    plot(TFA.time, TFA.power_Fmean(chan,:), 'Color','black','LineWidth',2.0 )
    plot(TFA.time, TFA.peakpower  (chan,:), 'Color','blue' ,'LineWidth',0.5 )
    l = legend('mean(power)','power@peakfreq');
    l.Interpreter = 'None';
    xlabel('Time (s)')
    ylabel('Power')
    axis tight
    
    % Tmean(powerspectrum)
    ax_Tmean(chan+1) = subplot('Position',pos_Tmean);
    plot(TFA.freq, TFA.power_Tmean(chan,:), 'Color','black','LineWidth',1 )
    xlabel('Frequency (Hz)')
    ylabel('Power')
    axis tight
    view([-90 90])

end % chan

axis(ax_3d,'tight')

% Link_3d = linkprop(ax_3d,{'CameraUpVector', 'CameraPosition', 'CameraTarget', 'XLim', 'YLim'});
% setappdata(figH, 'StoreTheLink_3d', Link_3d);

Link_Fmean = linkprop(ax_Fmean,{'XLim'});
setappdata(figH, 'StoreTheLink_Fmean', Link_Fmean);


%% Output ?

if nargout
    varargout{1} = figH;
end


end % function
