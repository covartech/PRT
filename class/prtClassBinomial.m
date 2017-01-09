classdef prtClassBinomial < prtClass
 %prtClassBinomial  Maximum a Posteriori classifier for binary data using
 %  IID binomial distributions for each feature (column) under each
 %  hypothesis (class)
 %
 %  Properties:
 %      
 %       priorSuccesses = 1e-3;  %I think I did this right.
 %       priorTrials = 10000e-3;
 %
 
    properties (SetAccess=private)
        name = 'Binomial'  
        nameAbbreviation = 'Binom'      
        isNativeMary = true;       
    end
    
    properties
        priorSuccesses = 1e-3;
        priorTrials = 10000e-3;
        pSuccessByClass = [];
    end
    
    methods
        % Constructor
        function self = prtClassBinomial(varargin)
            
            self.classTrain = 'prtDataInterfaceCategoricalTargets';
            self.classRun = 'prtDataSetBase';
            self.classRunRetained = false;
            
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function self = trainAction(self,ds)
            
            self.pSuccessByClass = [];
            for iClass = 1:ds.nClasses;
                classDs = ds.retainClassesByInd(iClass);
                pVec = (sum(classDs.X,1)+self.priorSuccesses)./(classDs.nObservations + self.priorTrials);
                pVec = full(pVec);
                self.pSuccessByClass(iClass,:) = pVec;
            end
        end
        
        function ds = runAction(self,ds)
            
            nClasses = size(self.pSuccessByClass,1);
            logLikelihoods = zeros(ds.nObservations, nClasses);
            for iY = 1:nClasses
                pVec = self.pSuccessByClass(iY,:);
                xOut = bsxfun(@times,ds.X,pVec) + bsxfun(@times,~ds.X,1-pVec);
                logLikelihoods(:,iY) = sum(log(xOut),2);
            end
            logLikelihoods = exp(bsxfun(@minus, logLikelihoods, prtUtilSumExp(logLikelihoods.').'));
            ds.X = logLikelihoods;
        end
    end
    methods
        function [sorted,pDist] = getSortedFeatures(self)
            % [sorted,pDist] = getSortedFeatures(self)
            %   Return the list of the features in sorted order.  pDist is
            %   the corresponding distance between the MLEs of the mean
            %   p(true)
            
            nClasses = size(self.pSuccessByClass,1);
            if nClasses ~= 2
                error('Only for binary problems');
            end
            pDist = self.pSuccessByClass(2,:)-self.pSuccessByClass(1,:);
            absDist = abs(pDist);
            [~,sorted] = sort(absDist,'descend');
            pDist = pDist(sorted);
            
        end
    end
    
end
