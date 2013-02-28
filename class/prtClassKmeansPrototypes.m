classdef prtClassKmeansPrototypes < prtClass
    % prtClassKmeansPrototypes  K-means prototypes classifier
    %
    %    CLASSIFIER = prtClassKmeansPrototypes returns a K-means prototypes
    %    classifier
    %
    %    CLASSIFIER = prtClassKmeansPrototypes(PROPERTY1, VALUE1, ...)
    %    constructs a prtClassKmeansPrototypes object CLASSIFIER with properties as
    %    specified by PROPERTY/VALUE pairs.
    %
    %    A prtClassKmeansPrototypes object inherits all properties from the
    %    abstract class prtClass. In addition is has the following
    %    properties:
    %
    %    nClustersPerHypothesis -  The number of clusters per hypothesis
    %
    %    clusterCenters         -  The cluster centers (set during
    %                              training)
    % 
    %    For information on the  K-means prototype classifier
    %    algorithm, please refer to:
    %
    %    Hastie, Tibshirani, Friedman, The Elements of Statistical Learning
    %
    %    A prtClassKmeansPrototypes object inherits the TRAIN, RUN,
    %    CROSSVALIDATE and KFOLDS methods from prtAction. It also inherits
    %    the PLOT method from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenMary;      % Create some test and 
    %     TrainingDataSet = prtDataGenMary;  % training data
    %     classifier = prtClassKmeansPrototypes; % Create a classifier
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     [~, classes] = max(classified.getX,[],2);          % Select the
    %                                                        % classes
    %     percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);
    %     classifier.plot;
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassGlrt,  prtClass

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


    properties (SetAccess=private)
        
        name = 'K-Means Prototypes' % K-Means Prototypes
        nameAbbreviation = 'K-MeansProto' % K-MeansProto
        isNativeMary = true;  % True
    end
    
    properties
        nClustersPerHypothesis = 2; % Number of clusters per hypothesis
    end
    
    properties (SetAccess = protected)
        clusterCenters = {};        % The cluster centers
    end
    
    properties (SetAccess = private, Hidden = true)
        uY = [];                    
    end
    properties (Hidden = true)
        kmeansHandleEmptyClusters = 'remove';
        distanceMetricFn = @prtDistanceEuclidean;
    end
    
    methods
        
        function Obj = prtClassKmeansPrototypes(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.nClustersPerHypothesis(Obj,val)
            if ~prtUtilIsPositiveScalarInteger(val)
                error('prt:prtClassKmeansPrototypes:nClustersPerHypothesis','nClustersPerHypothesis must be a positive integer scalar');
            end
            Obj.nClustersPerHypothesis = val;
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            
            Obj.uY = unique(DataSet.getTargets);
            nClusters = Obj.nClustersPerHypothesis;
            %For each class, extract the class centers:
            Obj.clusterCenters = cell(1,length(Obj.uY));
            for i = 1:length(Obj.uY)
                Obj.clusterCenters{i} = prtUtilKmeans(DataSet.getObservationsByClass(Obj.uY(i)),nClusters,'distanceMetricFn',Obj.distanceMetricFn,'handleEmptyClusters',Obj.kmeansHandleEmptyClusters);
            end
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            fn = Obj.distanceMetricFn;
            distance = nan(DataSet.nObservations,length(Obj.clusterCenters));
            selectedKMeansIndexes = nan(DataSet.nObservations,length(Obj.clusterCenters));
            for i = 1:length(Obj.clusterCenters)
                d = fn(DataSet.getObservations,Obj.clusterCenters{i});
                [distance(:,i), selectedKMeansIndexes(:,i)] = min(d,[],2);
            end
            
            %The smallest distance is the expected class:
            [dontNeed,ind] = min(distance,[],2);  %#ok<ASGLU>
            classes = Obj.uY(ind);  %note, use uY to get the correct label
            
            binaryMatrix = zeros(size(classes,1),length(Obj.uY));
            for i = 1:length(Obj.uY)
                currY = Obj.uY(i);
                binaryMatrix(currY == classes,i) = 1;
            end
            
            DataSet = DataSet.setObservations(binaryMatrix);
        end
    end
end
