classdef prtClassAdaBoost < prtClass
    %prtClassAdaBoost AdaBoost classifier
    %
    %    CLASSIFIER = prtClassAdaBoost returns a AdaBoost classifier
    %
    %    CLASSIFIER = prtClassAdaBoost(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassAdaBoost object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassAdaBoost object inherits all properties from the abstract
    %    class prtClass. In addition is has the following properties:
    %
    %    baseClassifier     - the prtClass object that forms the "weak" or
    %                         "Base" classifier for the AdaBoost.
    %    maxIters            - Number of iterations to run (number of weak
    %                         classifiers to train)
    %
    %    AdaBoost is a meta algorithm for training ensembles of weak
    %    classifiers on different sub-sets of the complete data set, with
    %    later classifiers trained to focus on data points that were
    %    mis-classified in earlier iterations.  A complete description of the
    %    algorithm for AdaBoost is beyond the scope of this help entry, but
    %    more information AdaBoost can be found at the following URL:
    %
    %    http://en.wikipedia.org/wiki/AdaBoost
    %
    %    A prtClassAdaBoost object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT
    %    method from prtClass.
    %
    %    Example:
    %
    %    TestDataSet = prtDataGenUnimodal;       % Create some test and
    %    TrainingDataSet = prtDataGenUnimodal;   % training data
    %    classifier = prtClassAdaBoost;                     % Create a classifier
    %    classifier = classifier.train(TrainingDataSet);    % Train
    %    classified = run(classifier, TestDataSet);         % Test
    %    subplot(2,1,1);
    %    classifier.plot;
    %    subplot(2,1,2);
    %    [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %    h = plot(pf,pd,'linewidth',3);
    %    title('ROC'); xlabel('Pf'); ylabel('Pd');
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassFld, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassGlrt,  prtClassSvm,
    %    prtClassTreeBaggingCap, prtClassKmsd, prtClassKnn
    
    
    properties (SetAccess=private)
        name = 'AdaBoost'    % AdaBoost
        nameAbbreviation = 'AdaBoost'  % AdaBoost
        isNativeMary = false;   % False
    end
    
    properties
        baseClassifier = prtClassFld; % The weak classifier
        maxIters = 100;  % Max number of iterations
        deltaPeThreshold = .1;
    end
    properties (Hidden)
        classifierArray = [];
        alpha = [];
    end
    
    methods
        % Constructor
        function Obj = prtClassAdaBoost(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        % Set function
        function Obj = set.baseClassifier(Obj,val)
            if (~isa(val,'prtClass'))
                error('prtClassAdaBoost:baseClassifier','baseClassifier parameter must be a prtClass');
            end
            Obj.baseClassifier = val;
        end
        
        
        function Obj = set.maxIters(Obj,val)
            if ~prtUtilIsPositiveScalarInteger(val)
                error('prt:prtClassAdaBoost:nBoosts','nBoosts must be a positive scalar integer');
            end
            Obj.maxIters = val;
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,dataSet)
            
            d = ones(dataSet.nObservations,1)./dataSet.nObservations;
            
            classifier = Obj.baseClassifier + prtDecisionBinaryMinPe;
            classifier.verboseStorage = false;
            classifier.verboseFeatureNames = true;
            
            classifierSet = repmat(classifier,dataSet.nFeatures,1);
            y = double(dataSet.getTargetsAsBinaryMatrix);
            y = y(:,2);
            y(y == 0) = -1;
            
            
            for t = 1:Obj.maxIters
                if t == 1
                    dataSetBootstrap = dataSet;
                else
                    dataSetBootstrap = dataSet.bootstrap(dataSet.nObservations,d);
                end
                
                pe = nan(dataSet.nFeatures,1);
                for feature = 1:dataSet.nFeatures
                    
                    tempClassifier = prtFeatSelStatic('selectedFeatures',feature)+classifier;
                    classifierSet(feature) = train(tempClassifier,dataSetBootstrap);
                    yOut = run(classifierSet(feature),dataSet);
                    
                    [~,correctLogical] = prtScorePercentCorrect(yOut);
                    pe(feature) = sum(double(~correctLogical).*d);
                end
                
                [minDeltaPe,minInd] = max(abs(pe-.5));
                
                if minDeltaPe < Obj.deltaPeThreshold
                    return;
                else
                    if t == 1
                        Obj.classifierArray = classifierSet(minInd);
                    else
                        Obj.classifierArray(t) = classifierSet(minInd);
                    end
                    Obj.alpha(t) = 1/2*log((1-pe(minInd))/pe(minInd));
                    
                    yOut = run(Obj.classifierArray(t),dataSet);
                    h = double(yOut.getObservations);
                    h(h == 0) = -1;
                    
                    d = d.*exp(-Obj.alpha(t).*y.*h);
                    
                    if sum(d) == 0
                        return;
                    end
                    d = d./sum(d);
                end
                
            end
        end
        
        function DataSetOut = runAction(Obj,DataSet)
            DataSetOut = prtDataSetClass(zeros(DataSet.nObservations,1));
            
            for t = 1:length(Obj.classifierArray)
                theObs = run(Obj.classifierArray(t),DataSet);
                currObs = Obj.alpha(t)*theObs.getObservations;
                DataSetOut = DataSetOut.setObservations(DataSetOut.getObservations + currObs);
            end
            
        end
        
    end
    
end