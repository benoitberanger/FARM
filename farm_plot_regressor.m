function varargout = farm_plot_regressor( reginfo )
% FARM_PLOT_REGRESSOR will plot the input and output of farm_make_regressor()
%
% SYNTAX
%              FARM_PLOT_REGRESSOR( reginfo )
%       figH = FARM_PLOT_REGRESSOR( reginfo )
%
% INPUT
%       - reginfo : see <a href="matlab: help farm_make_regressor">farm_make_regressor</a>
%
% See also farm_make_regressor farm_emg_regressor

if nargin==0, help(mfilename('fullpath')); return; end


%% Main

figH = figure('Name',reginfo.name,'NumberTitle','off');
figH.UserData = mfilename;

hold on

colors = lines(3);

if isfield(reginfo,'raw')
plot(reginfo.time_raw ,reginfo.raw  ,'LineStyle','-' ,'Color','black'    ,'DisplayName','raw'  )
end
plot(reginfo.time_in  ,reginfo.in   ,'LineStyle','-' ,'Color',colors(1,:),'DisplayName','in'   )

plot(reginfo.time_conv,reginfo.conv ,'LineStyle','-' ,'Color',colors(2,:),'DisplayName','conv' )
plot(reginfo.time_reg ,reginfo.reg  ,'LineStyle','-.','Color',colors(2,:),'DisplayName','reg'  )

plot(reginfo.time_conv,reginfo.dconv,'LineStyle','-' ,'Color',colors(3,:),'DisplayName','dconv')
plot(reginfo.time_reg ,reginfo.dreg ,'LineStyle','-.','Color',colors(3,:),'DisplayName','dreg' )

legend
xlabel('time (s)')


%% Output ?

if nargout
    varargout{1} = figH;
end


end % function
