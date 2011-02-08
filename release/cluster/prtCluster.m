classdef prtCluster < prtAction
    % prtCluster   Base class for prt clustering objects
    %
    %   prtCluster is an abstract class and cannot be instantiated. 
    %
    %   All prtCluster objects inherit all properities and methods from the
    %   prtAction object. 
    %
    %   prtCluster objects have the following methods:
    %
    %   plot          - Plot the output cluster of a trained clustering
    %                   algorithm. Only valid when the clutering algorithm
    %                   has been trained with a data set of 3 dimensions or
    %                   less.
    %
    %   In addition, ptCluster objects inherit the train, run,
    %   crossValidate and kfolds methods from prtAction.
    
    properties (Abstract)
        nClusters  % The number of clusters
    end
    properties (Dependent)
        internalDecider  % Optional prtDecider object for making decisions
    end
    properties (SetAccess = private, GetAccess = private, Hidden=true)
        internalDeciderDepHelper = [];
    end
    properties (Dependent)
        includesDecision % Flag indicating if result includes a decision
    end
    properties (SetAccess=protected, Hidden = true)
        yieldsMaryOutput = nan; % Determined in trainProcessing()
    end
    properties (Hidden = true)
        plotOptions = prtClass.initializePlotOptions(); 
    end
    properties (SetAccess = protected)
        isSupervised = false;
    end

    methods (Hidden = true)
        function featureNames = updateFeatureNames(obj,featureNames)
            if ~obj.includesDecision
                for i = 1:length(featureNames)
                    featureNames{i} = sprintf('%s Membership in cluster %d',obj.nameAbbreviation,i);
                end
            else
                featureNames{1} = 'Class label';
            end
        end
    end

    methods
        function obj = prtCluster()
            % As an action subclass we must set the properties to reflect
            % our dataset requirements
            obj.classTrain = 'prtDataSetClass';
            obj.classRun = 'prtDataSetStandard';
            obj.classRunRetained = true;
        end
        
        function val = get.internalDecider(obj)
            val = obj.internalDeciderDepHelper;
        end
        function obj = set.internalDecider(obj,val)
            if ~isempty(val) && ~isa(val,'prtDecision')
                error('prtClass:internalDecider','internalDecider must be an empty vector ([]) of type prtDecision, but input is a %s',class(val));
            end
            
            if ~isempty(val) && ~val.isTrained && obj.isTrained
                % We are adding a non-trained decision to a trained
                % classifier if we have verboseStorage = true we can train
                % the decider. If we don't we have to untrain and warn
                
                if ~isempty(obj.dataSet)
                    % We have the dataset
                    obj.internalDeciderDepHelper = val;
                    obj = postTrainProcessing(obj, obj.dataSet);
                    obj.yieldsMaryOutput = false;
                else
                    %Make obj.isTrained false:
                    obj.isTrained = false;
                    %warn user?
                    warning('prt:internalDecider:isTrained','Setting the internalDecider property of a prtClass object with an un-trained internalDecider sets the prtClass object''s isTrained to false');
                end
            else
                obj.internalDeciderDepHelper = val;
            end
            
        end
        
        function has = get.includesDecision(obj)
            has = ~isempty(obj.internalDecider);
        end
        
        function varargout = plot(Obj)
            % PLOT  Plot the output of the prtCluster object
            %
            %   OBJ.plot() plots the output confidence of a prtClass
            %   object. This function only operates when the dimensionality
            %   of dataset is 3 or less. When verboseStorage is set to
            %   'true', the training data points are also displayed on the
            %   plot.
            %
            %   See also: prtClass\plotDecision
            
            assert(Obj.isTrained,'Clusterer must be trained before it can be plotted.');
            assert(Obj.dataSetSummary.nFeatures < 4, 'nFeatures in the training dataset must be less than or equal to 3');
            
            if Obj.yieldsMaryOutput
                if ~isempty(Obj.dataSet)
                    warning('prt:prtClass:plot:autoDecision','prtCluster.plot() requires a prtCluster with an internal decider. A prtDecisionMap has been trained and set as the internalDecider to enable plotting.');
                else
                    error('prt:prtClass:plot','prtCluster.plot() requires a prtCluster with an internal decider. A prtDecisionMap cannot be trained and set as the internalDecider to enable plotting because this classifier object does not have verboseStorege turned on and therefore the dataSet used to train the classifier is unknow. To enable plotting, set an internalDecider and retrain the classifier.');
                end
                Obj.internalDecider = prtDecisionMap;
            end
            
            HandleStructure = plotBinaryClusterConfidence(Obj);
                
            if ~isempty(Obj.dataSet) && ~isempty(Obj.dataSet.name)
                title(sprintf('%s (%s)',Obj.name,Obj.dataSet.name));
            else
                title(Obj.name);
            end
            
            varargout = {};
            if nargout > 0
                varargout = {HandleStructure};
            end
        end
    end

    methods (Access = protected, Hidden = true)

        function Obj = postTrainProcessing(Obj,DataSet)
             if ~isempty(Obj.internalDecider)
                tempObj = Obj;
                tempObj.internalDecider = [];
                yOut = tempObj.run(DataSet);
                Obj.internalDecider = Obj.internalDecider.train(yOut);
                Obj.internalDecider.classList = 1:Obj.nClusters;
            end
        end

        function ClassObj = preTrainProcessing(ClassObj, DataSet)
            % Overload preTrainProcessing() so that we can determine mary
            % output status
            assert(isa(DataSet,'prtDataSetBase'),'DataSet must be a prtDataSetBase DataSet');

            ClassObj.yieldsMaryOutput = ~ClassObj.includesDecision; %determineMaryOutput(ClassObj,DataSet);

            ClassObj = preTrainProcessing@prtAction(ClassObj,DataSet);
        end

        function OutputDataSet = postRunProcessing(ClassObj, InputDataSet, OutputDataSet)
            % Overload postRunProcessing (from prtAction) so that we can
            % enforce twoClassParadigm
            
            if ~isempty(ClassObj.internalDecider)
                OutputDataSet = ClassObj.internalDecider.run(OutputDataSet);
            end
            
            OutputDataSet = postRunProcessing@prtAction(ClassObj, InputDataSet, OutputDataSet);
        end
        
        % Plotting functions
        function [OutputDataSet, linGrid, gridSize] = runClustererOnGrid(Obj, upperBounds, lowerBounds)

            if nargin < 3 || isempty(lowerBounds)
                lowerBounds = Obj.dataSetSummary.lowerBounds;
            end

            if nargin < 2 || isempty(upperBounds)
                upperBounds = Obj.dataSetSummary.upperBounds;
            end

            [linGrid, gridSize] = prtPlotUtilGenerateGrid(upperBounds, lowerBounds, Obj.plotOptions.nSamplesPerDim);

            OutputDataSet = run(Obj,prtDataSetClass(linGrid));
        end

        
        function HandleStructure = plotBinaryClusterConfidence(Obj)
            
            [OutputDataSet, linGrid, gridSize] = runClustererOnGrid(Obj);
            
            %internalDeciders* output the right colors:
            imageHandle = prtPlotUtilPlotGriddedEvaledClassifier(OutputDataSet.getObservations(), linGrid, gridSize, prtPlotUtilLightenColors(Obj.plotOptions.colorsFunction(Obj.nClusters)));
            
            if ~isempty(Obj.dataSet)
                hold on;
                handles = plot(Obj.dataSet);
                hold off;
                HandleStructure.Axes = struct('imageHandle',{imageHandle},'handles',{handles});
            else
                HandleStructure.Axes = struct('imageHandle',{imageHandle},'handles',{[]});
            end
        end
        
        function Obj = trainAutoDecision(Obj)
            if ~isempty(Obj.dataSet)
                    warning('prt:prtCluster:plot:autoDecision','prtCluster.plot() requires a prtCluster with an internal decider. A prtDecisionMap has been trained and set as the internalDecider to enable plotting.');
                    Obj.internalDecider =  prtDecisionMap;
                    Obj = postTrainProcessing(Obj, Obj.dataSet);
                    Obj.yieldsMaryOutput = false;
                else
                    error('prt:prtCluster:plot','prtCluster.plot() requires a prtCluster with an internal decider. A prtDecisionMap cannot be trained and set as the internalDecider to enable plotting because this cluster object does not have verboseStorege turned on and therefore the dataSet used to train the clusterer is unknow. To enable plotting, set an internalDecider and retrain the clusterer.');
            end
        end
    end

    methods (Static, Hidden = true)
        function plotOptions = initializePlotOptions()
            plotOptions = prtOptionsGet('prtOptionsClusterPlot');
        end
    end
end