classdef prtClassGlrt < prtClass
    % prtClassGlrt  Generlized likelihood ratio test classifier
    %
    %    CLASSIFIER = prtClassGlrt returns a Glrt classifier
    %
    %    CLASSIFIER = prtClassGlrt(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassGlrt object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassGlrt object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties:
    %
    %    rvH0 - A prtRvMvn object representing the mean and variance of
    %           hypothesis 0.
    %    rvH1 - A prtRvMvn object representing the mean and variance of
    %           hypothesis 0.
    % 
    %    For more information on Glrt classifiers, refer to the
    %    following URL:
    %  
    %    XXX Need ref
    %
    %    A prtClassGlrt object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT and
    %    PLOTDECISION classes from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenUniModal;       % Create some test and
    %     TrainingDataSet = prtDataGenUniModal;   % training data
    %     classifier = prtClassGlrt;              % Create a classifier
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     classes  = classified.getX > .5;
    %     percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);
    %     classifier.plot;
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassMaryEmulateOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassGlrt,  prtClass
    
    
    properties (SetAccess=private)
    
        name = 'Generalized likelihood ratio test'  % Generalized likelihood ratio test
        nameAbbreviation = 'GLRT'% GLRT
        isSupervised = true;  % True
        
        isNativeMary = false;  % False
        
    end 
    
    properties
       
        rvH0 = prtRvMvn;  % Mean and variance of H0
        
        rvH1 = prtRvMvn;  % Mean and variance of H1
    end
    
    methods
        function Obj = prtClassGlrt(varargin)
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            %Obj.verboseStorage = false;
        end
    end
    
    methods (Access=protected, Hidden = true)
       
        function Obj = trainAction(Obj,DataSet)
            
            Obj.rvH0 = mle(Obj.rvH0, DataSet.getObservationsByClass(0));
            Obj.rvH1 = mle(Obj.rvH1, DataSet.getObservationsByClass(1));
            
        end
        
        function ClassifierResults = runAction(Obj,DataSet)
            
            logLikelihoodH0 = logPdf(Obj.rvH0, DataSet.getObservations());
            logLikelihoodH1 = logPdf(Obj.rvH1, DataSet.getObservations());
            ClassifierResults = prtDataSetClass(logLikelihoodH1 - logLikelihoodH0);
        end
        
    end
end
