function varargout = prtPlotNativeMary(PrtClassifier) 
% imageHandle = prtPlotNativeMary(PrtClassifier) 

nDims = PrtClassifier.dataSetNFeatures;
if nDims > 3
    error('PrtClassifier.PrtDataSet.nFeatures (%d) must be less than or equal to 3',PrtClassifier.PrtDataSet.nFeatures);
end

% Make the meshgrid
[linGrid,gridSize] = prtPlotUtilGenerateGrid(PrtClassifier.dataSetLowerBounds, PrtClassifier.dataSetUpperBounds, PrtClassifier.PlotOptions);

% Run the PrtClassifier on the grid and reshape.
Results = prtRun(PrtClassifier,linGrid);

% So now we got this huge linear grid of data values.
[M,N] = getSubplotDimensions(Results.nFeatures);

classColors = feval(PrtClassifier.PlotOptions.colorsFunction, Results.nFeatures);

ha = cell([Results.nFeatures 1]);
imageHandle = cell([Results.nFeatures 1]);
for i = 1:Results.nFeatures;
    if M > 1 || N > 1
        subplot(M,N,i);
    end
    
    cPlotOptions = PrtClassifier.PlotOptions;
    cPlotOptions.twoClassColorMapFunction = @()prtPlotUtilLinspaceColormap([1 1 1], classColors(i,:)*0.8,256);
    
    data = reshape(Results.getObservations(:,i),gridSize);
    PlotOptions = PrtClassifier.PlotOptions;
    if isfield(PlotOptions,'mappingFunction') && ~isempty(PlotOptions.mappingFunction)
        data = feval(PlotOptions.mappingFunction, data);
    end

    prtPlotUtilImageEvaledClassifier(data,linGrid,gridSize,cPlotOptions);
    
    prtPlotUtilFreezeColors(gca);
    
    
    ha{i} = gca;
end

varargout = {};
% Ready the output
if nargout > 0
    varargout{1} = imageHandle;
    varargout{2} = ha;
end