classdef prtDecisionBinaryMinCost < prtDecisionBinary
    % prtDecisionBinaryMinCost Decision object for minimum cost
    %
    % prtDec = prtDecisionBinaryMinCost creates a prtDecisionBinaryMinCost
    % object, which can be used find a decision threshold in a binary
    % classification problem that minimizes the cost;
    %
    % prtDecisionBinaryMinCost objects are intended to be used either as members of
    % prtAlgorithm or prtClass objects.
    %
    % Properties:
    %       priors = 'equal'; % Either one of the strings 'equal',
    %          'empirical', or a 1x2 array of doubles, [pH0,pH1]
    %
    % Example 1:
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
        costMatrix = [0 -1; -1 0]; % Cost of [0|0, 1|0; 0|1, 1|1] - a.k.a. [true reject, false positive; false negative, true positive];
    end
    
    methods
        
        function self = prtDecisionBinaryMinCost(varargin)
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
            
            
            [pFalsePositive,pTruePositive,thresh] = prtScoreRoc(dataSet.getObservations,dataSet.getTargets);
            
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
                    case 'empiricalcounts'
                        pH0 = sum(dataSet.targets == 0);
                        pH1 = sum(dataSet.targets == 1);
                    otherwise
                        error('Invalid string: %s',self.priors);
                end
            elseif isnumeric(self.priors)
                pH0 = self.priors(1);
                pH1 = self.priors(2);
            else
                error('Invalid prior type: %s',class(self.priors));
            end
            costs = prtUtilPfPd2Cost(pFalsePositive,pTruePositive,self.costMatrix,pH0,pH1);
                        
            [v,minPeIndex] = min(costs); %#ok<ASGLU>
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
