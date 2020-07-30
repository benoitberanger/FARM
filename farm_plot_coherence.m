function varargout = farm_plot_coherence( data, coh, cfg )
% FARM_PLOT_TFA will plot the result of the farm_time_frequency_analysis_emg_acc
%
% SYNTAX
%              FARM_PLOT_TFA( data, coh )
%       figH = FARM_PLOT_TFA( data, coh )
%
% INPUTS
%       - data : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - coh  : output of <a href="matlab: help farm_coherence_analysis_emg_acc">farm_coherence_analysis_emg_acc</a>
%       - cfg  :
%                        foi //  (Hz) default=[4 6] frequency of interest
%               logtransform // (0/1) default=1     log-transform the result before display
%
% NOTES
%
%
% See also farm_time_frequency_analysis_emg_acc


if nargin==0, help(mfilename('fullpath')); return; end


%% Input parsing

if ~exist('cfg','var')
    cfg = [];
end

foi          = ft_getopt(cfg,          'foi', [4 6]); %  (Hz) frequency of interest
logtransform = ft_getopt(cfg, 'logtransform',     1); % (0/1) log-transform the result before display


%% Plot

foi_idx = coh.freq >= foi(1) & coh.freq <= foi(2);

figH = figure('Name',data.cfg.datafile,'NumberTitle','off');
figH.UserData = mfilename;
ax = axes(figH);
Title = sprintf('mean(coherence@[%d %d])', foi(1), foi(2));

img = mean(coh.cohspctrm(:,:,foi_idx),3);

if logtransform
    Title = ['log( ' Title ' )'];
    imagesc(ax, log(img));
else
    imagesc(ax,     img );
end

ax.Title.String         = Title;
figH.Colormap           = jet();
ax.XTickLabel           = coh.label;
ax.XTickLabelRotation   = 45;
ax.YTickLabel           = coh.label;
ax.TickLabelInterpreter = 'none';


%% Output ?

if nargout
    varargout{1} = figH;
end


end % function
