classdef prtClassKmeansPrototypes < prtClass
    % prtClassKmeansPrototypes  K-means prototypes classifier
    %
    %    CLASSIFIER = prtClassKmeansPrototypes returns a K-means prototypes
    %    classifier
    %
    %    CLASSIFIER = prtClassKmeansPrototypes(PROPERTY1, VALUE1, ...)
    %    constructs a prtClassMAP object CLASSIFIER with properties as
    %    specified by PROPERTY/VALUE pairs.
    %
    %    A prtClassKmeansPrototypes object inherits all properties from the
    %    abstract class prtClass. In addition is has the following
    %    properties:
    %
    %    nClustersPerHypothesis -  The number of clusters per hypothesis
    %    clusterCenters         -  The cluster centers 
    % 
    %    For information on the  K-means prototype classifier
    %    algorithm, please refer to:
    %
    %    Hastie, Tibshirani, Friedman, The Elements of Statistical Learning
    %
    %    A prtClassKmeansPrototypes object inherits the TRAIN, RUN,
    %    CROSSVALIDATE and KFOLDS methods from prtAction. It also inherits
    %    the PLOT and PLOTDECISION classes from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenMary;      % Create some test and 
    %     TrainingDataSet = prtDataGenMary;  % training data
    %     classifier = prtClassKmeansPrototypes; % Create a classifier
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     [~, classes] = max(classified.getX,[],2);              % Select the
    %                                                        % classes
    %     percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);
    %     classifier.plot;
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassMaryEmulateOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassGlrt,  prtClass
    
    
    % prtClassKmeansPrototypes
    %   Unsupervised clustering on data in each hypothesis, then supervised
    %   classify with closest prototype
    
    properties (SetAccess=private)
        
        name = 'K-Means Prototypes' % K-Means Prototypes
        nameAbbreviation = 'K-MeansProto' % K-MeansProto
        isSupervised = true; % True
        
        % Required by prtClass
        isNativeMary = true;  % True
    end
    
    properties
        nClustersPerHypothesis = 2; % Number of clusters per hypothesis
        clusterCenters = {};        % The cluster centers
        distanceMetricFn = @prtDistanceEuclidean;
       % uY = [];                    % uY ?
    end
    properties (SetAccess = private, Hidden = true)
        uY = [];                    % uY ?
    end
    
    methods
        
        function Obj = prtClassKmeansPrototypes(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            
            Obj.uY = unique(DataSet.getTargets);
            nClusters = Obj.nClustersPerHypothesis;
            %For each class, extract the Fuzzy K-Means class centers:
            Obj.clusterCenters = cell(1,length(Obj.uY));
            for i = 1:length(Obj.uY)
                Obj.clusterCenters{i} = prtUtilKmeans(DataSet.getObservationsByClass(Obj.uY(i)),nClusters,'distanceMetricFn',Obj.distanceMetricFn);
            end
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            fn = Obj.distanceMetricFn;
            distance = nan(DataSet.nObservations,length(Obj.clusterCenters));
            for i = 1:length(Obj.clusterCenters)
                d = fn(DataSet.getObservations,Obj.clusterCenters{i});
                distance(:,i) = min(d,[],2);
            end
            
            %The smallest distance is the expected class:
            [~,ind] = min(distance,[],2);
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