classdef prtDecisionBinaryMinPe < prtDecisionBinary
    % xxx NEED HELP xxx
    %
    % prtDecisionBinaryMinPe prt Decision action to find a threshold in a
    % binary problem to minimize the probability of error.
    %
    % Examples (as part of an algorithm):
    %
    % ds = prtDataGenBimodal;
    % classifier = prtClassKnn;
    % classifier = classifier.train(ds);
    % yOutClassifier = classifier.run(ds);
    %
    % algo = prtClassKnn + prtDecisionBinaryMinPe;
    % algo = algo.train(ds);
    % yOutAlgorithm = algo.run(ds);
    % subplot(2,1,1); stem(yOutClassifier.getObservations); title('KNN Output');
    % subplot(2,1,2); stem(yOutAlgorithm.getObservations); title('KNN + Decision Output');
    %
    % Example (as an internalDecider object):
    %
    % ds = prtDataGenBimodal;
    % classifier = prtClassKnn;
    % classifier = classifier.train(ds);
    % subplot(2,1,1); plot(classifier); title('KNN');
    %
    % classifier.internalDecider = prtDecisionBinaryMinPe;
    % classifier = classifier.train(ds);
    % subplot(2,1,2); plot(classifier); title('KNN + Decision');
    %    	
    
    properties (SetAccess = private)
        name = 'MinPe'
        nameAbbreviation = 'MINPE';
        isSupervised = true;
    end
    properties (Hidden = true)
        threshold
        uniqueClasses
    end
    methods
        
        function obj = prtDecisionBinaryMinPe(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end
    methods (Access = protected)
        function Obj = trainAction(Obj,dataSet)
            
            if dataSet.nFeatures > 1
                error('prt:prtDecisionBinaryMinPe','prtDecisionBinaryMinPe can not be used on algorithms that output multi-column results; consider using prtDecisionMap instead');
            end
            [pf,pd,thresh] = prtScoreRoc(dataSet.getObservations,dataSet.getTargets);
            pe = prtUtilPfPd2Pe(pf,pd);
            [v,minPeIndex] = min(pe); %#ok<ASGLU>
            Obj.threshold = thresh(minPeIndex);
            Obj.classList = dataSet.uniqueClasses;
        end
    end
    methods
        function threshold = getThreshold(Obj)
            threshold = Obj.threshold;
        end
        function uniqueClasses = getUniqueClasses(Obj)
            uniqueClasses = Obj.uniqueClasses;
        end
    end
end