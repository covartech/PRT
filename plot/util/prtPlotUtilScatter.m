function h = prtPlotUtilScatter(cX, featureNames, classSymbols, classColors, classEdgeColor, linewidth, markerSize)
% Internal function PRT function

% Copyright (c) 2013 New Folder Consulting
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


nPlotDimensions = size(cX,2);
if nPlotDimensions < 1
    warning('prt:prtPlotUtilScatter:NoPlotDimensionality','No plot dimensions requested.');
    return
end
if nPlotDimensions > 3
    error('prt:prtPlotUtilScatter:plotDimensionality','The number of requested plot dimensions (%d) is greater than 3. You may want to use explore() to select and visualize a subset of the features.',nPlotDimensions);
end

switch nPlotDimensions
    case 1
        h = plot(cX,ones(size(cX)),classSymbols,'MarkerFaceColor',classColors,'MarkerEdgeColor',classEdgeColor,'linewidth',linewidth,'MarkerSize',markerSize);
        if ~isempty(featureNames)
            xlabel(featureNames{1});
        end
        set(gca,'YTick',[]);
        grid on
    case 2
        h = plot(cX(:,1),cX(:,2),classSymbols,'MarkerFaceColor',classColors,'MarkerEdgeColor',classEdgeColor,'linewidth',linewidth,'MarkerSize',markerSize);
        if ~isempty(featureNames)
            xlabel(featureNames{1});
            ylabel(featureNames{2});
        end
        grid on
    case 3
        h = plot3(cX(:,1),cX(:,2),cX(:,3),classSymbols,'MarkerFaceColor',classColors,'MarkerEdgeColor',classEdgeColor,'linewidth',linewidth,'MarkerSize',markerSize);
        if ~isempty(featureNames)
            xlabel(featureNames{1});
            ylabel(featureNames{2});
            zlabel(featureNames{3});
        end
        grid on;
end
