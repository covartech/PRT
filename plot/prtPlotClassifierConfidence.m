function imageHandle = prtPlotClassifierConfidence(PrtClassifier)
% varargout = prtPlotClassifierContours(PrtClassifier)

nDims = PrtClassifier.DataSetSummary.nFeatures;
if nDims > 3
    error('prt:prtActionPlot:tooManyDimensions','PrtDataSet.nFeatures (%d) must be less than or equal to 3',PrtClassifier.dataSetNFeatures);
end

[isMary, isEmulated] = prtUtilDetermineMary(PrtClassifier);
if isMary
     if ~isEmulated
         % Native M-ary
         imageHandle = prtPlotNativeMary(PrtClassifier);
     else
         % We need to call the plot function specified in the
         % MaryEmulationOptions
         plotFunction = PrtClassifier.Classifiers(1).PrtOptions.MaryEmulationOptions.plotFunction;
         imageHandle = feval(plotFunction, PrtClassifier);
     end
     return
end
% Binary output - Either native or Emulated 

% Make the Meshgrid
[linGrid,gridSize] = prtPlotUtilGenerateGrid(PrtClassifier.dataSetLowerBounds, PrtClassifier.dataSetUpperBounds, PrtClassifier.PlotOptions);

% Run the PrtClassifier on the grid and reshape.
Results = prtRun(PrtClassifier,linGrid);
data = reshape(Results.getObservations(),gridSize);

PlotOptions = PrtClassifier.PlotOptions;
if isfield(PlotOptions,'mappingFunction') && ~isempty(PlotOptions.mappingFunction)
    data = feval(PlotOptions.mappingFunction, data);
end

wasHold = ishold;

% Plot the grid
imageHandle = prtPlotUtilImageEvaledClassifier(data,linGrid,gridSize,PlotOptions);
title(PrtClassifier.name);

% Check for PrtClassifier-specific plotting functions:
if isfield(PlotOptions,'additionalPlotFunction') && ~isempty(PlotOptions.additionalPlotFunction);
    feval(PlotOptions.additionalPlotFunction,PrtClassifier);
end

% Take care of some hold stuff
if ~wasHold
    hold off
end
