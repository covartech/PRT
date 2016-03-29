classdef prtRegressBayesianLinear < prtRegress
    %prtRegressBayesianLinear Bayesian Linear Regression object
    %
    %   REGRESS = prtRegressBayesianLinear returns a prtRegressBayesianLinear object
    %
    %   See also prtRegress, prtRegressRvm, prtRegressGP


    properties (SetAccess=private)
        name = 'Bayesian Linear Regression'
        nameAbbreviation = 'BLR'
    end
    
    properties 
        includeBias = true;
        
        priorWeightsMean = 0; % If scalar will be initialized by replication
        priorWeightsPrecision = eps; % If scalar will be 
        
        priorPrecisionA = 0.1;
        priorPrecisionB = 0.1;
        
        
        mu
        lambda
        a
        b
        
        weightMean = []; % Will be the same as mu
        weightCovariance = [];
        weightDof = [];
        noisePrecisionMean = [];
        
        weightConfidenceBound = [];
    end
    
    methods
        
          % Allow for string, value pairs
        function self = prtRegressBayesianLinear(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function self = trainAction(self,ds)
           
           d = ds.nFeatures + self.includeBias;
           if isscalar(self.priorWeightsMean)
               self.priorWeightsMean = self.priorWeightsMean*ones(1,d);
           end
           if isscalar(self.priorWeightsPrecision)
               self.priorWeightsPrecision = self.priorWeightsPrecision*eye(d);
           end
           
           lambda0 = self.priorWeightsPrecision;
           mu0 = self.priorWeightsMean;
           a0 = self.priorPrecisionA;
           b0 = self.priorPrecisionB;
           
           X = ds.X;
           if self.includeBias
               X = cat(2,ones(size(X,1),1),X);
           end
           y = ds.Y;
           
           XtX = X'*X;
           
           self.lambda = (XtX + lambda0);
           self.mu = (mu0*lambda0+ y'*X)/(self.lambda);
           
           self.a = a0 + size(X,1)/2;
           self.b = b0 + (y'*y + mu0*lambda0*mu0' - self.mu*self.lambda*self.mu')/2;
           
           self.weightMean = self.mu;
           self.noisePrecisionMean = self.b./self.a;
           self.weightCovariance = inv(self.lambda)/self.noisePrecisionMean;
           self.weightDof = self.a;
           
           self.weightConfidenceBound = bsxfun(@plus,[-1; 1]*sqrt(diag(self.weightCovariance)')*2, self.weightMean);
        end
        
        function ds = runAction(self,ds)
            
            X = ds.getObservations;
            if self.includeBias
                X = cat(2,ones(size(X,1),1),X);
            end
            
            ds = ds.setObservations(X*self.weightMean');
        end
        
    end
    
end
