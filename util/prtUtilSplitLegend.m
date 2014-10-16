function prtUtilSplitLegend(axisH,symbolH,labelH)
% prtUtilSplitLegend split the current legend into two parts on either 
%   side of the axes
%
% prtUtilSplitLegend with no input arguments splits the current legend in half
% 
% prtUtilSplitLegend(axisHandle,lineHandles,strings) makes a legend on the current
% axes for the specified lines, with the specified strings.
%
% % Examples:
% close all;
% h = plot(rand(5,40));
% strings = prtUtilCellPrintf('%d',num2cell(1:40));
% legend(h,strings);
% prtUtilSplitLegend
%
% % Or:
% h = plot(rand(5,40));
% strings = prtUtilCellPrintf('%d',num2cell(1:40));
% prtUtilSplitLegend(gca,h,strings);
% 

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
    axisH = gca;
    [legendH,~,symbolH] = legend;
    labelH = get(legendH,'String');
end
    
    
border = 0.05;        % Normalized
innerBorder = 0;

% Test legend width
midPt = round(length(symbolH)/2);
lgEastH = legend(gca,symbolH(midPt+1:end),labelH(midPt+1:end),'Location','EastOutside');
lgEastPos = get(lgEastH,'Position');
legendWidth = lgEastPos(3);

% Set axis location
legend(axisH,'off')
currentAxisPos = get(axisH,'OuterPosition');
newAxisPos = [...
    (border+innerBorder+legendWidth),...
    currentAxisPos(2),...
    (1 -(2*border)- (2*innerBorder)-(2*legendWidth)),...
    currentAxisPos(4)];
set(axisH,'OuterPosition',newAxisPos);

% Set up east legend
eastLegendPos = [...
    ((2*innerBorder)+border+legendWidth+newAxisPos(3)),...
    lgEastPos(2),...
    legendWidth,...
    lgEastPos(4)];
lgEastH = legend(gca,symbolH(midPt+1:end),labelH(midPt+1:end),'Location','EastOutside');
set(lgEastH,'Position',eastLegendPos);

% Set up west legend
extraAxisH = axes('Position',get(gca,'Position'),'Visible','off');
lgWestH = legend(extraAxisH,symbolH(1:midPt),labelH(1:midPt),'Location','WestOutside');
lgWestPos = get(lgWestH,'Position');
westLegendPos = [...
    border,...
    lgWestPos(2),...
    legendWidth,...
    lgWestPos(4)];
set(lgWestH,'Position',westLegendPos)

axes(axisH);

