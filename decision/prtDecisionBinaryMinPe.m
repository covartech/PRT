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
    % Properties:
    %       priors = 'equal'; % Either one of the strings 'equal',
    %          'empirical', or a 1x2 array of doubles, [pH0,pH1]
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
    properties
        priors = 'equal'; % 'equal', 'empirical' (estimated from data), or [pH0, pH1]
    end
    methods
        
        function self = prtDecisionBinaryMinPe(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    methods (Access=protected,Hidden=true)
        function self = trainAction(self,dataSet)
            
            if dataSet.nFeatures > 1
                error('prt:prtDecisionBinaryMinPe','prtDecisionBinaryMinPe can not be used on algorithms that output multi-column results; consider using prtDecisionMap instead');
            end
            if dataSet.nClasses ~= 2
                error('prt:prtDecisionBinaryMinPe:nonBinaryData','prtDecisionBinaryMinPe expects input data to have 2 classes, but dataSet.nClasses = %d',dataSet.nClasses);
            end
            
            
            [pf,pd,thresh] = prtScoreRoc(dataSet.getObservations,dataSet.getTargets);
            if isa(self.priors,'char')
                switch lower(self.priors);
                    case 'equal'
                        pH0 = 0.5;
                        pH1 = 0.5;
                    case 'empirical'
                        nH0 = sum(dataSet.targets == 0);
                        nH1 = sum(dataSet.targets == 1);
                        pH0 = nH0./dataSet.nObservations;
                        pH1 = nH1./dataSet.nObservations;
                    otherwise
                        error('Invalid string: %s',self.priors);
                end
            elseif isnumeric(self.priors)
                pH0 = self.priors(1);
                pH1 = self.priors(2);
            else
                error('Invalid prior type: %s',class(self.priors));
            end
            pe = prtUtilPfPd2Pe(pf,pd,pH0,pH1);
            
            [v,minPeIndex] = min(pe); %#ok<ASGLU>
            self.threshold = thresh(minPeIndex);
            self.classList = dataSet.uniqueClasses;
        end
    end
    methods
        function threshold = getThreshold(self)
             % THRESH = getThreshold returns the objects threshold
            threshold = self.threshold;
        end
        function uniqueClasses = getUniqueClasses(self)
            uniqueClasses = self.uniqueClasses;
        end
    end
    
end
