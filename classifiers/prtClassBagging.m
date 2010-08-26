classdef prtClassBagging < prtClass
     % prtClassBagging  Bagging classifier
    %
    %    CLASSIFIER = prtClassBagging returns a bagging classifier
    %
    %    CLASSIFIER = prtClassBagging(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassBagging object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassBagging object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties:
    %
    %    prtClassifier  - The classifier to be used
    %    nBags          - The number of bags
    % 
    %    For more information on bagging classifiers, refer to the
    %    following URL:
    %
    %
    %    http://en.wikipedia.org/wiki/Bootstrap_aggregating
    %
    %    A prtClassBagging object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT and
    %    PLOTDECISION classes from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenUniModal;       % Create some test and
    %     TrainingDataSet = prtDataGenUniModal;   % training data
    %     classifier = prtClassBagging;           % Create a classifier
    %     classifier.prtClassifier = prtClassMap;  % Set the classifier to
    %                                             % a prtClassMap
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
        % Required by prtAction
        name = 'Bagging Classifier'   %  Bagging Classifier
        nameAbbreviation = 'Bagging'  %  Bagging
        isSupervised = true;          %  True
        
        isNativeMary = false;         % False
    end
    
    properties
        prtClassifier = prtClassFld;  % The classifier to be bagged
        nBags = 100;                  % The number of bags
    end
    properties (SetAccess=protected, Hidden = true)
        Classifiers
    end
    
    methods
        
        function Obj = prtClassBagging(varargin)
           
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)

            for i = 1:Obj.nBags
                if i == 1
                    Obj.Classifiers = train(Obj.prtClassifier,DataSet.bootstrap(DataSet.nObservations));
                else
                    Obj.Classifiers(i) = train(Obj.prtClassifier,DataSet.bootstrap(DataSet.nObservations));
                end
            end
        end
        
        function yOut = runAction(Obj,DataSet)
            yOut = DataSet;
            for i = 1:Obj.nBags
                Results = run(Obj.Classifiers(i),DataSet);
                if i == 1
                    yOut = yOut.setObservations(Results.getObservations);
                else
                    yOut = yOut.setObservations(yOut.getObservations + Results.getObservations);
                end
            end
            yOut = yOut.setObservations(yOut.getObservations./Obj.nBags);
        end
        
    end
    
end