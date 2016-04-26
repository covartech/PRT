classdef prtDecisionBinaryMinPe < prtDecisionBinary
    % prtDecisionBinaryMinPe Decision object for minimum probability of
    % error in binary classification
    %
    % prtDec = prtDecisionBinaryMinPe creates a prtDecisionBinaryMinPe
    % object, which can be used find a decision threshold in a binary
    % classification problem that minimizes the probability of error.
    %
    % prtDecision objects are intended to be used either as members of
    % prtAlgorithm or prtClass objects.
    %
    % Example 1:
    %
    % ds = prtDataGenBimodal;              % Load a data set
    % classifier = prtClassKnn;            % Create a clasifier
    % classifier = classifier.train(ds);   % Train the classifier
    % yOutClassifier = classifier.run(ds); % Run the classifier
    %
    % % Construct a prtAlgorithm object consisting of a prtClass object and
    % % a prtDecision object
    % algo = prtClassKnn + prtDecisionBinaryMinPe; 
    %
    % algo = algo.train(ds);        % Train the algorithm    
    % yOutAlgorithm = algo.run(ds); % Run the algorithm
    % 
    % % Plot and compare the results
    % subplot(2,1,1); stem(yOutClassifier.getObservations); title('KNN Output');
    % subplot(2,1,2); stem(yOutAlgorithm.getObservations); title('KNN + Decision Output');
    %
    % Example 2:
    %
    % ds = prtDataGenBimodal;              % Load a data set
    % classifier = prtClassKnn;            % Create a clasifier
    % classifier = classifier.train(ds);   % Train the classifier
    %
    % % Plot the trained classifier
    % subplot(2,1,1); plot(classifier); title('KNN');
    %
    % % Set the classifiers internealDecider to be a prtDecsion object
    % classifier.internalDecider = prtDecisionBinaryMinPe;
    %
    % classifier = classifier.train(ds); % Train the classifier
    % subplot(2,1,2); plot(classifier); title('KNN + Decision');
    %    	
    % See also: prtDecisionBinary, prtDecisionBinarySpecifiedPd,
    % prtDecisionBinarySpecifiedPf, prtDecisionMap







    properties (SetAccess = private)
        name = 'MinPe'   % MinPe
        nameAbbreviation = 'min(Pe)';  % MINPE
        threshold
    end
    properties (Hidden = true)
        uniqueClasses
    end
    methods
        
        function obj = prtDecisionBinaryMinPe(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end
    methods (Access=protected,Hidden=true)
        function Obj = trainAction(Obj,dataSet)
            
            if dataSet.nFeatures > 1
                error('prt:prtDecisionBinaryMinPe','prtDecisionBinaryMinPe can not be used on algorithms that output multi-column results; consider using prtDecisionMap instead');
            end
            if dataSet.nClasses ~= 2
                error('prt:prtDecisionBinaryMinPe:nonBinaryData','prtDecisionBinaryMinPe expects input data to have 2 classes, but dataSet.nClasses = %d',dataSet.nClasses);
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
             % THRESH = getThreshold returns the objects threshold
            threshold = Obj.threshold;
        end
        function uniqueClasses = getUniqueClasses(Obj)
            uniqueClasses = Obj.uniqueClasses;
        end
    end
    
end
