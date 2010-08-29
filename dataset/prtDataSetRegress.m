classdef prtDataSetRegress < prtDataSetStandard
    % prtDataSetRegress   Data set object for regression
    %
    %   DATASET = prtDataSetRegress returns a prtDataSetRegress object
    %
    %   DATASET = prtDataSetRegress(PROPERTY1, VALUE1, ...) constructs a
    %   prtDataSetRegress object DATASET with properties as specified by
    %   PROPERTY/VALUE pairs.
    %
    %   A prtDataSetRegress object inherits all properties from the
    %   prtDataSetStandard class. 
    %
    %   A prtDataSetRegress inherits all methods from the
    %   prtDataSetStandard object. In addition it overloads the following
    %   functions:
    %
    %   plot      - Plot the prtDataSetRegress object
    %   summarize - Summarize the prtDataSetRegress object.
    % 
    %   See also prtDataSetStandard, prtDataSetClass, prtDataSetBase
    
    properties (Hidden = true)
        PlotOptions = prtDataSetRegress.initializePlotOptions()
    end
    
    methods
        %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function prtDataSet = prtDataSetRegress(varargin)
  
            prtDataSet = prtDataSet@prtDataSetStandard(varargin{:});
        end
        
        function varargout = plot(obj, featureIndices)
            % Plot   Plot the prtDataSetRegress object
            %
            %   dataSet.plot() Plots the prtDataSetRegress object.
            
            if ~obj.isLabeled
                obj = obj.setTargets(zeros(obj.nObservations,1));
            end
            
            if nargin < 2 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
            if islogical(featureIndices)
                featureIndices = find(featureIndices);
            end
            
            nPlotDimensions = length(featureIndices);
            if nPlotDimensions < 1
                warning('prt:plot:NoPlotDimensionality','No plot dimensions requested.');
                return
            elseif nPlotDimensions >= 2
                error('prt:plot:NoPlotDimensionality','Regression plots are currently only valid for 1 dimensional data, but DataSet has %d dimensions',obj.nFeatures);
            end
            
            holdState = get(gca,'nextPlot');
            
            classColors = obj.PlotOptions.colorsFunction(1);
            markerSize = obj.PlotOptions.symbolSize;
            lineWidth = obj.PlotOptions.symbolLineWidth;
            classSymbols = obj.PlotOptions.symbolsFunction(1);
            
            iPlot = 1;
            classEdgeColor = obj.PlotOptions.symbolEdgeModificationFunction(classColors(iPlot,:));
            
            h = plot(obj.getObservations,obj.getTargets, classSymbols(iPlot), 'MarkerFaceColor', classColors(iPlot,:), 'MarkerEdgeColor', classEdgeColor,'linewidth',lineWidth,'MarkerSize',markerSize);
            
            set(gca,'nextPlot',holdState);
            
            % Set title
            title(obj.name);
            switch nPlotDimensions
                case 1
                    xlabel(obj.getFeatureNames());
                    ylabel(obj.getTargetNames());
                otherwise
                    error('prt:plot:NoPlotDimensionality','Regression plots are currently only valid for 1 dimensional data, but DataSet has %d dimensions',obj.nFeatures);
            end
            
            % Handle Outputs
            varargout = {};
            if nargout > 0
                varargout = {h};
            end
        end
        
        function Summary = summarize(Obj)
            % Summarize   Summarize the prtDataSetRegress object
            %
            % SUMMARY = dataSet.summarize() Summarizes the dataSetRegress
            % object and returns the result in the struct SUMMARY.
            
            Summary.upperBounds = max(Obj.getObservations());
            Summary.lowerBounds = min(Obj.getObservations());
            Summary.nFeatures = Obj.nFeatures;
            Summary.nTargetDimensions = Obj.nTargetDimensions;
            Summary.nObservations = Obj.nObservations;
        end
    end
    methods (Static, Hidden = true)
        function PlotOptions = initializePlotOptions()
            UserOptions = prtUserOptions;
            PlotOptions = UserOptions.DataSetRegressPlotOptions;
        end
    end
end
