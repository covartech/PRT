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
 %    nBoosts            - Number of iterations to run (number of weak
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
 

    properties (SetAccess=private)
        % Required by prtAction
        name = 'AdaBoost' 
        nameAbbreviation = 'AdaBoost'
        isNativeMary = false;
    end
    
    properties
        baseClassifier = prtClassFld;
        nBoosts = 30;
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
            if(~ isa(val, 'prtClass'))
                error('prtClassAdaBoost:baseClassifier','baseClassifier parameter must be a prtClass');
            else
                Obj.baseClassifier = val;
            end
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,dataSet)
            
            d = ones(dataSet.nObservations,1)./dataSet.nObservations;

            for t = 1:Obj.nBoosts
                if t == 1
                    dataSetBootstrap = dataSet;
                else
                    dataSetBootstrap = dataSet.bootstrap(dataSet.nObservations,d);
                end
                
                Obj.classifierArray{t} = train(Obj.baseClassifier + prtDecisionBinaryMinPe,dataSetBootstrap);
                yOut = run(Obj.classifierArray{t},dataSet);

                y = double(dataSet.getTargetsAsBinaryMatrix);
                y = y(:,2);
                y(y == 0) = -1;
                h = double(yOut.getObservations);
                h(h == 0) = -1;
                pe = sum(double(y~=h).*d);
                
                Obj.alpha(t) = 1/2*log((1-pe)/pe);
                d = d.*exp(-Obj.alpha(t).*y.*h);
                if sum(d) == 0
                    return;
                end
                d = d./sum(d);
                
                if pe > .5
                    return;
                end
            end
        end
        
        function DataSetOut = runAction(Obj,DataSet)
            DataSetOut = prtDataSetClass(zeros(DataSet.nObservations,1));
            
            for t = 1:length(Obj.classifierArray)
                theObs = run(Obj.classifierArray{t},DataSet);
                currObs = Obj.alpha(t)*theObs.getObservations;
                DataSetOut = DataSetOut.setObservations(DataSetOut.getObservations + currObs);
            end

        end
        
    end
    
end