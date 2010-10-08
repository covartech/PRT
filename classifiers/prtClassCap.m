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
    %        
    %    w                 -  Central axis projection weights, set during
    %                         training
    %    threshold         -  Decision threshold, set during training
    %    thresholdSampling -  The number of neighbors to consider in the
    %                         nearest-neighbor voting.
    % 
    %    For more information on Cap classifiers, refer to the
    %    following URL:
    %  
    %    XXX Need ref
    %
    %    A prtClassCap object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT and
    %    PLOTDECISION classes from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenUniModal;       % Create some test and
    %     TrainingDataSet = prtDataGenUniModal;   % training data
    %     classifier = prtClassCap;              % Create a classifier
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     classes  = classified.getX > .5;
    %     percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);
    %     classifier.plot;
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassMaryEmulateOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassDlrt,  prtClass
    
    
    
    
    
    properties (SetAccess=private)
    
        name = 'Central Axis Projection' % Central Axis Projection
        nameAbbreviation = 'CAP' % CAP
        isSupervised = true; % True
        
       
        isNativeMary = false; % False
        
        % Central axis projection weights
        w = [];
        % Decision threshold
        threshold = []; 
    end 
    
    properties
        thresholdSampling = 100; % The number of neighbors to consider in the nearest-neighbor voting.
    end
    
    methods
        function Obj = prtClassCap(varargin)
          
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        function Obj = trainAction(Obj,DataSet)
            
            y = DataSet.getTargets;
            x = DataSet.getObservations;
            mean0 = mean(DataSet.getObservationsByClass(0),1);
            mean1 = mean(DataSet.getObservationsByClass(1),1);
            
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
                    warning('Min PE from CAP.trainAction is >= 0.5');
                end
            end
            Obj.threshold = thresholdValue;
        end
        
        function [thresholdValue,minPe] = optimizeThreshold(Obj,x,y)
            yOut = (Obj.w*x')';
            
            if Obj.thresholdSampling > length(y)
                [pf,pd,~,thresh] = prtScoreRoc(yOut,y);
            else
                [pf,pd,~,thresh] = prtScoreRoc(yOut,y,Obj.thresholdSampling);
            end
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
