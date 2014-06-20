function xTickTextHandles = prtUtilConvertXtickLabelsToObjets(hAxes,varargin)
%xTickTextHandles = prtUtilConvertXaxisText(hAxes)
%   xTickTextHandles = prtUtilConvertXaxisText(hAxes)
%   xTickTextHandles = prtUtilConvertXaxisText
%
%
%   ds = prtDataGenMarysSimpleSixClass;
%   c = prtClassKnn + prtDecisionMap;
%   yOut = c.kfolds(ds,10);
%   prtScoreConfusionMatrix(yOut)
%   h = prtUtilConvertXtickLabelsToObjets;
%   set(h,'rotation',20); %You'll need to adjust the positions of all the
%                         % xTickLabels, xlabels, etc.

if nargin == 0
    hAxes = gca;
end
strings = get(hAxes,'xticklabel');
xLocs = get(hAxes,'xtick');

axis(hAxes);   % Set the axis limit modes (e.g. XLimMode) to manual
v = axis;

if strcmpi(get(hAxes,'YDir'),'reverse')
    yLims = v(4:-1:3);
else
    yLims = v(3:4);  % Y-axis limits
end
% Place the text labels
xTickTextHandles = text(xLocs,yLims(1)*ones(1,length(xLocs)),strings);
set(xTickTextHandles,'HorizontalAlignment','center','VerticalAlignment','top');

% % Remove the default labels
set(hAxes,'XTickLabel','')
