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

% Copyright (c) 2014 CoVar Applied Technologies
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


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
