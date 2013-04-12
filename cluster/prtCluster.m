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
    %   A prtCluster object inherits the TRAIN, RUN, CROSSVALIDATE and KFOLDS
    %   functions from the prtAction object.
    %
    %   See also prtClusterGmm, prtClusterKmeans

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


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
        isSupervised = false;  % False
        isCrossValidateValid = true; % True
	end
	
	methods (Hidden = true)
        function featureNameModificationFunction = getFeatureNameModificationFunction(self)
            if ~self.includesDecision
				featureNameModificationFunction = prtUtilFeatureNameModificationFunctionHandleCreator('%s Membership in cluster #index#', self.nameAbbreviation);
			else
				featureNameModificationFunction = prtUtilFeatureNameModificationFunctionHandleCreator('Class Label');
            end
        end
	end
	
    methods
        function self = prtCluster()
            % As an action subclass we must set the properties to reflect
            % our dataset requirements
            self.classTrain = 'prtDataSetClass'; % Can't this be prtDataSetStandard?
            self.classRun = 'prtDataSetStandard';
            self.classRunRetained = true;
        end
        
        function val = get.internalDecider(self)
            val = self.internalDeciderDepHelper;
        end
        function self = set.internalDecider(self,val)
            if ~isempty(val) && ~isa(val,'prtDecision')
                error('prtClass:internalDecider','internalDecider must be an empty vector ([]) of type prtDecision, but input is a %s',class(val));
            end
            
            if ~isempty(val) && ~val.isTrained && self.isTrained
                % We are adding a non-trained decision to a trained
                % classifier if we have verboseStorage = true we can train
                % the decider. If we don't we have to untrain and warn
                
                if ~isempty(self.dataSet)
                    % We have the dataset
                    self.internalDeciderDepHelper = val;
                    self = postTrainProcessing(self, self.dataSet);
                    self.yieldsMaryOutput = false;
                else
                    %Make self.isTrained false:
                    self.isTrained = false;
                    %warn user?
                    warning('prt:internalDecider:isTrained','Setting the internalDecider property of a prtClass object with an un-trained internalDecider sets the prtClass object''s isTrained to false');
                end
            else
                self.internalDeciderDepHelper = val;
            end
            
        end
        
        function has = get.includesDecision(self)
            has = ~isempty(self.internalDecider);
        end
        
        function varargout = plot(self)
            % PLOT  Plot the output of the prtCluster object
            %
            %   OBJ.plot() plots the output confidence of a prtClass
            %   object. This function only operates when the dimensionality
            %   of dataset is 3 or less. When verboseStorage is set to
            %   'true', the training data points are also displayed on the
            %   plot.
            %
            %   See also: prtClass\plotDecision
            
            assert(self.isTrained,'Clusterer must be trained before it can be plotted.');
            assert(self.dataSetSummary.nFeatures < 4, 'nFeatures in the training dataset must be less than or equal to 3');
            
            if self.yieldsMaryOutput
                self = trainAutoDecision(self);
            end
            
            handleStructure = plotBinaryClusterConfidence(self);
                
            if ~isempty(self.dataSet) && ~isempty(self.dataSet.name)
                title(sprintf('%s (%s)',self.name,self.dataSet.name));
            else
                title(self.name);
            end
            
            varargout = {};
            if nargout > 0
                varargout = {handleStructure};
            end
        end
    end

    methods (Access = protected, Hidden = true)

        function self = postTrainProcessing(self,ds)
             if ~isempty(self.internalDecider)
                tempself = self;
                tempself.internalDecider = [];
                yOut = tempself.run(ds);
                self.internalDecider = self.internalDecider.train(yOut);
                self.internalDecider.classList = 1:self.nClusters;
            end
        end

        function self = preTrainProcessing(self, ds)
            % Overload preTrainProcessing() so that we can determine mary
            % output status
            
            self.yieldsMaryOutput = ~self.includesDecision;

            self = preTrainProcessing@prtAction(self, ds);
        end

        function outputDs = postRunProcessing(self, inputDs, outputDs)
            % Overload postRunProcessing (from prtAction) so that we can
            % enforce the internaldecider
            
            if ~isempty(self.internalDecider)
                outputDs = self.internalDecider.run(outputDs);
            end
            
            outputDs = postRunProcessing@prtAction(self, inputDs, outputDs);
        end
        
        % Plotting functions
        function [outputDs, linGrid, gridSize] = runClustererOnGrid(self, upperBounds, lowerBounds)

            if nargin < 3 || isempty(lowerBounds)
                lowerBounds = self.dataSetSummary.lowerBounds;
            end

            if nargin < 2 || isempty(upperBounds)
                upperBounds = self.dataSetSummary.upperBounds;
            end

            [linGrid, gridSize] = prtPlotUtilGenerateGrid(upperBounds, lowerBounds, self.plotOptions.nSamplesPerDim);

            outputDs = run(self,prtDataSetClass(linGrid));
        end

        
        function handleStructure = plotBinaryClusterConfidence(self)
            
            [outputDs, linGrid, gridSize] = runClustererOnGrid(self);
            
            %internalDeciders* output the right colors:
            imageHandle = prtPlotUtilPlotGriddedEvaledClassifier(outputDs.getObservations(), linGrid, gridSize, prtPlotUtilLightenColors(self.plotOptions.colorsFunction(self.nClusters)),self);
            
            if ~isempty(self.dataSet)
                hold on;
                handles = plot(self.dataSet);
                hold off;
                handleStructure.Axes = struct('imageHandle',{imageHandle},'handles',{handles});
            else
                handleStructure.Axes = struct('imageHandle',{imageHandle},'handles',{[]});
            end
        end
        
        function self = trainAutoDecision(self)
            if ~isempty(self.dataSet)
                % warning('prt:prtCluster:plot:autoDecision','prtCluster.plot() requires a prtCluster with an internal decider. A prtDecisionMap has been trained and set as the internalDecider to enable plotting.');
                
                % It is much easier (and safer) to just train the
                % prtDecisionMap
                self.internalDecider = prtDecisionMap;
                self = postTrainProcessing(self, self.dataSet);
                self.yieldsMaryOutput = false;
            else
                % warning('prt:prtCluster:plot:autoDecision','prtCluster.plot() requires a prtCluster with an internal decider. A prtDecisionMap has been trained and set as the internalDecider to enable plotting.');
                % error('prt:prtCluster:plot','prtCluster.plot() requires a prtCluster with an internal decider. A prtDecisionMap cannot be trained and set as the internalDecider to enable plotting because this cluster object does not have verboseStorege turned on and therefore the dataSet used to train the clusterer is unknow. To enable plotting, set an internalDecider and retrain the clusterer.');
                
                % Since we don't have the dataset we just mock train
                % This is slightly dangerous in the case when
                % prtDecisionMap changes to include more parameters. or
                % dataSetSummary changes. (It is currently only a struct)
                tempInternalDecider = prtDecisionMap;
                tempInternalDecider.isTrained = true;
                tempInternalDecider.classList = 1:self.nClusters;
                tempInternalDecider.dataSetSummary = self.dataSetSummary;
                tempInternalDecider.dataSetSummary.nFeatures = self.nClusters;
                
                self.internalDecider = tempInternalDecider;
            end
        end
    end

    methods (Static, Hidden = true)
        function plotOptions = initializePlotOptions()            
            if ~isdeployed
                plotOptions = prtOptionsGet('prtOptionsClusterPlot');
            else
                plotOptions = prtOptions.prtOptionsClusterPlot;
            end
        end
    end
end
