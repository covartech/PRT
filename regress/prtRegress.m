classdef prtRegress < prtAction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prtRegress is an abstract base class for all regression objects.







    properties
        plotOptions = prtRegress.initializePlotOptions(); % Plotting Options
    end
    
    properties (SetAccess = protected)
        isSupervised = true; % True
        isCrossValidateValid = true; % True
	end
	
    methods (Hidden = true)
        function featureNameModificationFunction = getFeatureNameModificationFunction(obj)
			featureNameModificationFunction = prtUtilFeatureNameModificationFunctionHandleCreator('%s Output_{#index#}', obj.nameAbbreviation);
        end
	end    
    
    methods
        function obj = prtRegress()
            % As an action subclass we must set the properties to reflect
            % our dataset requirements
            obj.classTrain = 'prtDataSetRegress';
            obj.classRun = 'prtDataSetStandard';
            obj.classRunRetained = true;
        end        
        
        function varargout = plot(Obj)
            % PLOT  Plot the prtRegress object
            %
            % OBJ.plot() plots a trained prtRegress object. The plot
            % displays the original data points, the regressed data points,
            % and a line or curve interpolating between the regressed data
            % points.
            
            
            assert(Obj.isTrained,'Regressor must be trained before it can be plotted.');
            
            [OutputDataSet, linGrid] = runRegressorOnGrid(Obj);
            
            colors = Obj.plotOptions.colorsFunction(Obj.dataSetSummary.nTargetDimensions);
            lineWidth = Obj.plotOptions.lineWidth;
            
            switch Obj.dataSetSummary.nFeatures
                case 1
                    HandleStructure.regressorPlotHandle = plot(linGrid,OutputDataSet.getObservations,'color',colors(1,:),'lineWidth',lineWidth);
                case 2
                    sz = ones(1,Obj.dataSetSummary.nFeatures)*Obj.plotOptions.nSamplesPerDim(Obj.dataSetSummary.nFeatures);
                    HandleStructure.regressorPlotHandle = surf(...
                        reshape(linGrid(:,1),sz),...
                        reshape(linGrid(:,2),sz),...
                        reshape(OutputDataSet.getObservations,sz));
                    HandleStructure.regressorPlotHandle.EdgeColor = colors(1,:);
                    HandleStructure.regressorPlotHandle.FaceColor = 'none';
                    HandleStructure.regressorPlotHandle.LineWidth = lineWidth;
                otherwise
                    error('nFeatures in the training dataset must be 1 or 2');
            end
            
            holdState = get(gca,'nextPlot');
            if ~isempty(Obj.dataSet)
                hold on
                HandleStructure.dataSetPlotHandle = plot(Obj.dataSet);
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
                lowerBounds = Obj.dataSetSummary.lowerBounds;
            end
            
            if nargin < 2 || isempty(upperBounds)
                upperBounds = Obj.dataSetSummary.upperBounds;
            end
            
            [linGrid, gridSize] = prtPlotUtilGenerateGrid(upperBounds, lowerBounds, Obj.plotOptions.nSamplesPerDim);
            
            OutputDataSet = run(Obj,prtDataSetRegress(linGrid));
        end
    end
    methods (Static, Hidden = true)
        function plotOptions = initializePlotOptions()
            if ~isdeployed
                plotOptions = prtOptionsGet('prtOptionsRegressPlot');
            else
                plotOptions = prtOptions.prtOptionsRegressPlot;
            end
        end
    end
end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
