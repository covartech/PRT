classdef prtRegress < prtAction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prtRegress is an abstract base class for all regression objects.

    properties
        PlotOptions = prtRegress.initializePlotOptions(); % Plotting Options
    end
    
    methods (Hidden = true)
        function featureNames = updateFeatureNames(obj,featureNames) %#ok<MANU>
            for i = 1:length(featureNames)
                featureNames{i} = sprintf('%s Output_{%d}',obj.nameAbbreviation,i);
            end
        end
    end    
    
    methods
        function varargout = plot(Obj)
            % PLOT  Plot the output confidence of a prtClass object
            %
            %   OBJ.plot() plots the output confidence of a prtClass
            %   object. This function only operates when the dimensionality
            %   of dataset is 3 or less. When verboseStorage is set to
            %   'true', the training data points are also displayed on the
            %   plot.
            
            
            assert(Obj.isTrained,'Regressor must be trained before it can be plotted.');
            assert(Obj.DataSetSummary.nFeatures < 2, 'nFeatures in the training dataset must be 1');
            
            [OutputDataSet, linGrid] = runRegressorOnGrid(Obj);
            
            colors = Obj.PlotOptions.colorsFunction(Obj.DataSetSummary.nTargetDimensions);
            lineWidth = Obj.PlotOptions.lineWidth;
            HandleStructure.regressorPlotHandle = plot(linGrid,OutputDataSet.getObservations,'color',colors(1,:),'lineWidth',lineWidth);
            
            holdState = get(gca,'nextPlot');
            if ~isempty(Obj.DataSet)
                hold on
                HandleStructure.dataSetPlotHandle = plot(Obj.DataSet);
            end
            set(gca,'nextPlot',holdState);
            
            axis tight;
            title(Obj.name)
            
            varargout = {};
            if nargout > 0
                varargout = {HandleStructure};
            end
        end
        function [OutputDataSet, linGrid, gridSize] = runRegressorOnGrid(Obj, upperBounds, lowerBounds)
            
            if nargin < 3 || isempty(lowerBounds)
                lowerBounds = Obj.DataSetSummary.lowerBounds;
            end
            
            if nargin < 2 || isempty(upperBounds)
                upperBounds = Obj.DataSetSummary.upperBounds;
            end
            
            [linGrid, gridSize] = prtPlotUtilGenerateGrid(upperBounds, lowerBounds, Obj.PlotOptions.nSamplesPerDim);
            
            OutputDataSet = run(Obj,prtDataSetClass(linGrid));
        end
    end
    methods (Static, Hidden = true)
        function PlotOptions = initializePlotOptions()
            PlotOptions = prtOptionsGet('prtOptionsRegressPlot');
        end
    end
end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%