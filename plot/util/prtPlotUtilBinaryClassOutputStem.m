function varargout = prtPlotUtilBinaryClassOutputStem(dataSetClass,offSet)
% prtPlotUtilBinaryClassOutputStem  Decision Statistic Stem Plot for the PRT
%
% Syntax: [H, L] = prtPlotUtilBinaryClassOutputStem(ds,Y,opt)
%







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





