function varargout = prtPlotUtilBinaryClassOutputStem(dataSetClass,offSet)
% prtPlotUtilBinaryClassOutputStem  Decision Statistic Stem Plot for the PRT
%
% Syntax: [H, L] = prtPlotUtilBinaryClassOutputStem(ds,Y,opt)
%

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


if dataSetClass.nFeatures > 1
    error('prt:plotUtilBinaryClassOutputStem','prtPlotUtilBinaryClassOutputStem is only for data sets with a single feature.');
end

colors = prtPlotUtilClassColors(dataSetClass.nClasses);
symbols = prtPlotUtilClassSymbols(dataSetClass.nClasses);
holdState = ishold;

[sortedDs, sortedDsInds] = sort(dataSetClass.getObservations(),'descend');

Y = dataSetClass.getTargets();
H = zeros(dataSetClass.nClasses,1);
for iY = 1:dataSetClass.nClasses
    
    iInds = Y(sortedDsInds)==dataSetClass.uniqueClasses(iY);
    iDs = sortedDs(iInds);
    
    H(iY) = stem(find(iInds),iDs,symbols(iY),'color',colors(iY,:),'MarkerFaceColor',colors(iY,:),'MarkerSize',3);
    
    if iY == 1
        hold on;
    end
end
% This doesn't work like I want it to.
%set(gca,'XTick',1:length(ds),'XTickLabel',num2str(sortedDsInds),'XTickMode','auto');
set(gca,'XTick',[]);


obsStrs = dataSetClass.getObservationNames;
obsStrs = obsStrs(sortedDsInds);

textHandles = zeros(dataSetClass.nObservations,1);
dontPlot = ~cellfun(@isempty,strfind(obsStrs,'Observation'));
for iObs = 1:dataSetClass.nObservations
    if ~dontPlot(iObs)
        textHandles(iObs) = text(iObs+offSet(1),sortedDs(iObs)+offSet(2),obsStrs{iObs},'Interpreter','none');
    end
end
legend(dataSetClass.getClassNames,'Location','NorthEast')
xlabel('Observation')
ylabel('Decision Statistic')

if holdState
    hold on;
else
    hold off;
end

varargout = {};
if nargout > 0
    varargout = {H,textHandles};
end





