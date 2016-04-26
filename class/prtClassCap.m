classdef prtClassCap < prtClass
    % prtClassCap  Central Axis projection classifier
    %
    %    CLASSIFIER = prtClassCap returns a Cap classifier
    %
    %    CLASSIFIER = prtClassCap(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassCap object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassCap object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties:
    %
    %    w                 -  Central axis projection weights, set during
    %                         training
    %    threshold         -  Decision threshold, set during training
    %
    %    Cap classifiers are a prototypical "weak" classification algorithm
    %    that find application in multiple meta-algorithms.  A good
    %    explanation of Cap classifiers can be found in:
    %
    %    Breiman, Leo (2001). "Random Forests". Machine Learning 45 (1): 
    %    5–32.
    %
    %    Note that the output of the run method of a prtClassCap classifier
    %    includes the process of applying the learned threshold to the
    %    linear projection, so the outputs are discrete valued.
    %
    %    A prtClassCap object inherits the TRAIN, RUN, CROSSVALIDATE and 
    %    KFOLDS methods from prtAction. It also inherits the PLOT method 
    %    from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenUniModal;       % Create some test and
    %     TrainingDataSet = prtDataGenUniModal;   % training data
    %     classifier = prtClassCap;              % Create a classifier
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     percentCorr = prtScorePercentCorrect(classified,TestDataSet);
    %     subplot(2,1,1);
    %     classifier.plot;
    %     subplot(2,1,2);
    %     [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %     h = plot(pf,pd,'linewidth',3);
    %     title('ROC'); xlabel('Pf'); ylabel('Pd');
    %







    
    properties (SetAccess=private)
        
        name = 'Central Axis Projection' % Central Axis Projection
        nameAbbreviation = 'CAP' % CAP
        isNativeMary = false; % False
        
        % Central axis projection weights
        w = [];
        % Decision threshold
        threshold = [];
    end
    
    methods
        function Obj = prtClassCap(varargin)
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        function Obj = trainAction(Obj,DataSet)
            
            
            if ~DataSet.isBinary
                error('prtClassCap:nonBinaryTraining','Input dataSet for prtClassCap.train must be binary');
            end
            
            
            %y = DataSet.getTargets;
            y = DataSet.getBinaryTargetsAsZeroOne;
            x = DataSet.getObservations;
            mean0 = mean(DataSet.getObservationsByClassInd(1),1);
            mean1 = mean(DataSet.getObservationsByClassInd(2),1);
            
            Obj.w = mean1 - mean0;
            Obj.w = Obj.w./norm(Obj.w);
            
            %Evaluate the thresold using w:
            Obj = optimizeThresholdPosNeg(Obj,x,y);
        end
        
        function Obj = optimizeThresholdPosNeg(Obj,x,y)
            [thresholdValue,minPe] = optimizeThreshold(Obj,x,y);
            
            %It's possible that for oddly distributed data, the weight
            %vector will point in the wrong direction, yielding a ROC curve
            %that never goes above the chance diagonal; when this happens,
            %try inverting the w vector, and re-run optimizeThreshold
            if minPe >= 0.5
                Obj.w = -Obj.w;
                [thresholdValue,minPe] = optimizeThreshold(Obj,x,y);
                if minPe >= 0.5
                    warning('prt:prtClassCap','Min PE from CAP.trainAction is >= 0.5');
                end
            end
            Obj.threshold = thresholdValue;
        end
        
        function [thresholdValue,minPe] = optimizeThreshold(Obj,x,y)
            yOut = (Obj.w*x')';
            
            [pf,pd,thresh] = prtScoreRoc(yOut,y);
            
            pE = prtUtilPfPd2Pe(pf,pd);
            [minPe,I] = min(pE);
            thresholdValue = thresh(unique(I));
        end
        
        function ClassifierResults = runAction(Obj,PrtDataSet)
            
            x = getObservations(PrtDataSet);
            
            y = (Obj.w*x')';
            y = y - Obj.threshold;
            y(y >= 0) = 1;
            y(y < 0) = 0;
            
            ClassifierResults = prtDataSetClass(y);
            
        end
        
    end
end
