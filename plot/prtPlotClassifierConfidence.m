function imageHandle = prtPlotClassifierConfidence(PrtClassifier,PrtDataSet)
%varargout = prtPlotClassifierContours(PrtClassifier,PrtDataSet)
%   Note: this breaks if pre-processing included.  we still have to figure
%   out how to do that
%
%   Should work for native M-ary
%
%   Not sure about emulated M-ary

if nargin == 1
    PrtDataSet = [];
end

nDims = PrtClassifier.PrtDataSet.nFeatures;
if nDims > 3
    error('PrtClassifier.PrtDataSet.nFeatures (%d) must be less than or equal to 3',PrtClassifier.PrtDataSet.nFeatures);
end

[isMary, isEmulated] = prtUtilDetermineMary(PrtClassifier);
if isMary
    if ~isEmulated
        imageHandle = feval(PrtClassifier.PrtOptions.PlotOptions.nativeMaryPlotFunction,PrtClassifier,PrtDataSet);
    else
        % We need to call the plot function specified in the
        % MaryEmulationOptions
        plotFunction = PrtClassifier.Classifiers(1).PrtOptions.MaryEmulationOptions.plotFunction;
        imageHandle = feval(plotFunction,varargin{:});
    end
    return
end

if ~isfield(PrtClassifier.PrtOptions,'PlotOptions')
    PrtClassifier.PrtOptions.PlotOptions = optionsDprtPlot;
end

% % Now we remove the PreProcess field so when we run the grid we don't
% % pre process it.
% if isfield(PrtClassifier.PrtOptions,'PreProcess')
%     PrtClassifier.PrtOptions = rmfield(PrtClassifier.PrtOptions,'PreProcess');
% end

% Make the Meshgrid
[linGrid,gridSize] = prtPlotUtilGenerateGrid(PrtClassifier,PrtDataSet);

% Run the PrtClassifier on the grid and reshape.
Results = prtRun(PrtClassifier,linGrid);
data = reshape(Results.data,gridSize);

PlotOptions = PrtClassifier.PrtOptions.PlotOptions;
if isfield(PlotOptions,'mappingFunction') && ~isempty(PlotOptions.mappingFunction)
    DS = feval(PlotOptions.mappingFunction,DS);
end

wasHold = ishold;

% Plot the grid
imageHandle = prtPlotUtilImageEvaledClassifier(data,linGrid,gridSize,PlotOptions);
title(PrtClassifier.PrtOptions.Private.classifierName);

% Check for PrtClassifier-specific plotting functions:
if isfield(PlotOptions,'additionalPlotFunction') && ~isempty(PlotOptions.additionalPlotFunction);
    feval(PlotOptions.additionalPlotFunction,PrtClassifier);
end

% Take care of some hold stuff
if ~wasHold
    hold off
end
