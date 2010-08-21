%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef prtRegress < prtAction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % PreProcessors are currently have no additional properties or methods
    % This is a placeholder for consistency with other action types
    
    properties
        PlotOptions = prtClassPlotOpt; % Plotting Options
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
            %
            %   See also: prtClass\plotDecision
            
            assert(Obj.isTrained,'Regressor must be trained before it can be plotted.');
            assert(Obj.DataSetSummary.nFeatures < 2, 'nFeatures in the training dataset must be 1');
            
            [OutputDataSet, linGrid] = runRegressorOnGrid(Obj);
            HandleStructure.regressorPlotHandle = plot(linGrid,OutputDataSet.getObservations,'r');
            if ~isempty(Obj.DataSet)
                hold on;
                HandleStructure.dataSetPlotHandle = plot(Obj.DataSet);
                hold off;
            end
            
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
            
            [linGrid, gridSize] = prtPlotUtilGenerateGrid(upperBounds, lowerBounds, Obj.PlotOptions);
            
            OutputDataSet = run(Obj,prtDataSetClass(linGrid));
        end
    end
end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%