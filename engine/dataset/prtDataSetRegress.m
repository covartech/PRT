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
        plotOptions = prtDataSetRegress.initializePlotOptions()
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
                error('prt:plot:NoPlotDimensionality','Regression plots are currently only valid for 1 dimensional data, but the requested plot has %d dimensions',nPlotDimensions);
            end
            
            holdState = get(gca,'nextPlot');
            
            classColors = obj.plotOptions.colorsFunction(1);
            markerSize = obj.plotOptions.symbolSize;
            lineWidth = obj.plotOptions.symbolLineWidth;
            classSymbols = obj.plotOptions.symbolsFunction(1);
            
            iPlot = 1;
            classEdgeColor = obj.plotOptions.symbolEdgeModificationFunction(classColors(iPlot,:));
            
            h = plot(obj.getObservations(:,featureIndices),obj.getTargets, classSymbols(iPlot), 'MarkerFaceColor', classColors(iPlot,:), 'MarkerEdgeColor', classEdgeColor,'linewidth',lineWidth,'MarkerSize',markerSize);
            
            set(gca,'nextPlot',holdState);
            
            % Set title
            title(obj.name);
            switch nPlotDimensions
                case 1
                    xlabel(obj.getFeatureNames(featureIndices));
                    ylabel(obj.getTargetNames(1));
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
        function plotOptions = initializePlotOptions()
            plotOptions = prtOptionsGet('prtOptionsDataSetRegressPlot');
        end
    end
end
