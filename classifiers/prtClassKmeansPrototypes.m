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
    %    For information on the  K-nearest neighbors classifier
    %    algorithm, please refer to the following URL:
    %
    %    XXX Need ref
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
    %     classes  = classified.getX;
    %     percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);
    %     classifier.plot;
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassMaryEmulateOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassGlrt,  prtClass
    
    
    % prtClassKmeansPrototypes
    %   Unsupervised clustering on data in each hypothesis, then classify
    %   with closest prototype
    
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
       % uY = [];                    % uY ?
    end
    properties (SetAccess = private, Hidden = true)
        fuzzyKMeansOptions = prtUtilOptFuzzyKmeans;
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
            Obj.fuzzyKMeansOptions.nClusters = Obj.nClustersPerHypothesis;
            %For each class, extract the Fuzzy K-Means class centers:
            Obj.clusterCenters = cell(1,length(Obj.uY));
            for i = 1:length(Obj.uY)
                Obj.clusterCenters{i} = prtUtilFuzzyKmeans(DataSet.getObservationsByClass(Obj.uY(i)),Obj.fuzzyKMeansOptions);
            end
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            fn = Obj.fuzzyKMeansOptions.distanceMeasure;
            distance = nan(DataSet.nObservations,length(Obj.clusterCenters));
            for i = 1:length(Obj.clusterCenters)
                d = fn(DataSet.getObservations,Obj.clusterCenters{i});
                distance(:,i) = min(d,[],2);
            end
            
            %The smallest distance is the expected class:
            [~,ind] = min(distance,[],2);
            classes = Obj.uY(ind);  %note, use uY to get the correct label
            
            DataSet = DataSet.setObservations(classes);
        end
        
    end
    
end