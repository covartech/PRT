function h = prtPlotUtilDataSetPlotIndividual(ds)

origHoldState = ishold;

h = zeros(ds.nObservations,1);
nFeatures = ds.nFeatures;
X = ds.X;
for iObs = 1:ds.nObservations
    switch nFeatures
        case 1
            h(iObs) = plot(X(iObs,1),'.');
        case 2
            h(iObs) = plot(X(iObs,1),X(iObs,2),'.');
        case 3
            h(iObs) = plot3(X(iObs,1),X(iObs,2),X(iObs,3),'.');
        otherwise
             error('prt:prtPlotUtilDataSetPlotIndividual:plotDimensionality','The number of requested plot dimensions (%d) is greater than 3. You may want to use explore() to select and visualize a subset of the features.',nPlotDimensions);
    end
    hold on
end
if ~origHoldState
    hold off
end
