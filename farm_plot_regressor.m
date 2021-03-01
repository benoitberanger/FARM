function varargout = farm_plot_regressor( data, reginfo )
% FARM_PLOT_REGRESSOR will plot the input and output of farm_make_regressor()
%
% SYNTAX
%              FARM_PLOT_REGRESSOR( data, reginfo )
%       figH = FARM_PLOT_REGRESSOR( data, reginfo )
%
% INPUT
%       - data    : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - reginfo : see <a href="matlab: help farm_make_regressor">farm_make_regressor</a>
%
% See also farm_make_regressor farm_emg_regressor

if nargin==0, help(mfilename('fullpath')); return; end


%% Main

figH          = figure('Name',data.cfg.datafile,'NumberTitle','off');
figH.UserData = mfilename;
ax            = axes(figH);

hold on

colors = lines(5);

if isfield(reginfo,'raw')
plot(ax,reginfo.time_raw ,reginfo.raw      ,'LineStyle','-' ,'Color','black'    ,'DisplayName','raw'  )
end
plot(ax,reginfo.time_in  ,reginfo.in       ,'LineStyle','-' ,'Color',colors(1,:),'DisplayName','in'   )

plot(ax,reginfo.time_conv,reginfo.     conv,'LineStyle','-' ,'Color',colors(2,:),'DisplayName','conv' )
plot(ax,reginfo.time_reg ,reginfo.     reg ,'LineStyle','-.','Color',colors(2,:),'DisplayName','reg'  )

plot(ax,reginfo.time_conv,reginfo.    dconv,'LineStyle','-' ,'Color',colors(3,:),'DisplayName','dconv')
plot(ax,reginfo.time_reg ,reginfo.    dreg ,'LineStyle','-.','Color',colors(3,:),'DisplayName','dreg' )

plot(ax,reginfo.time_conv,reginfo. log_conv,'LineStyle','-' ,'Color',colors(4,:),'DisplayName','log_conv' )
plot(ax,reginfo.time_reg ,reginfo. log_reg ,'LineStyle','-.','Color',colors(4,:),'DisplayName','log_reg'  )

plot(ax,reginfo.time_conv,reginfo.dlog_conv,'LineStyle','-' ,'Color',colors(5,:),'DisplayName','dlog_conv')
plot(ax,reginfo.time_reg ,reginfo.dlog_reg ,'LineStyle','-.','Color',colors(5,:),'DisplayName','dlog_reg' )

l               = legend;
l.Interpreter   = 'None';
xlabel('time (s)')
ax.Title.String = reginfo.name;
ax.Title.Interpreter = 'None';

%% Output ?

if nargout
    varargout{1} = figH;
end


end % function
