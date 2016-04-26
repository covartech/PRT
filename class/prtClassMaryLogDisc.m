classdef prtClassMaryLogDisc < prtClass







    
    properties (SetAccess=private)
        name = 'bleh'  % Logistic Discriminant
     
        nameAbbreviation = 'meh'  % LogDisc
     
        isNativeMary = true;  % True
    end
    
    properties (SetAccess = protected)
        % w  
        %   w is a DataSet.nDimensions + 1 x 1 vector of projection weights
        %   learned during LogDisc.train(DataSet)
        
        wMat = [];  % Regression weights
        
        % nIterations
        %   Number of iterations used in training.  This is set to a number
        %   between 1 and maxIter during training.
        
        nIterations = nan;  % The number of iterations used in training
        wChangeTolerance = 1e-2;
        converged = false;
    end
    
    properties
        % maxIter
        %   Maximum number of iterations to allow before exiting without
        %   convergence.
        
        maxIter = 500;  % Maxmimuum number of iterations
    end
    
    methods
        
        function self = prtClassMaryLogDisc(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function self = set.maxIter(self,val)
            if ~prtUtilIsPositiveScalarInteger(val)
                error('prt:prtClassLogisticDiscriminant:maxIter','maxIter must be a positive scalar integer');
            end
            self.maxIter = val;
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            %self = trainAction(self,dataSet)
            
            x = dataSet.getObservations;
            x = cat(2,ones(size(x,1),1),x); %DC component
            y = dataSet.getTargetsAsBinaryMatrix;
            
            nClasses = dataSet.nClasses;
            d = size(x,2);
            
            %random initialization; last set of weights is set to 0
            numWeights = d*(nClasses-1);
            weightMatrix = randn(nClasses-1,d);
            weightMatrix = cat(1,weightMatrix,zeros(1,size(weightMatrix,2)));
            weightMatrixOld = weightMatrix;
            
            %Can calculate B matrix outside loop; makes life fast
            xx = x'*x;
            B = kron(-1/2*(eye(nClasses-1)-ones(nClasses-1)/dataSet.nClasses),xx);
            
            self.converged = false;
            Binv = B^-1;
            for j = 1:self.maxIter
                psi = (weightMatrix*x')';
                py = bsxfun(@rdivide,exp(psi),sum(exp(psi),2));
                
                %label error
                yError = y-py;
                
                %Can we speed this up?  KRON is needlessly slow
                g = 0;
                for i = 1:size(yError,1)
                    g = g + kron(yError(i,:),x(i,:));
                end
                g = g(:);
                
                % Update weightMatrix in direction of gradient
                weightMatrix(1:end-1,:) = weightMatrix(1:end-1,:) - reshape((Binv*g(1:numWeights)),d,nClasses-1)';
                
                if norm(weightMatrix(:)-weightMatrixOld(:)) < self.wChangeTolerance
                    self.converged = true;
                    break;
                end
                weightMatrixOld = weightMatrix;
                
            end
            self.wMat = weightMatrix;
        end
        
        function ClassifierResults = runAction(self,dataSet)
            %ClassifierResults = runAction(self,DataSet)
            
            x = dataSet.getObservations;
            x = cat(2,ones(size(x,1),1),x);
            
            psi = (self.wMat*x')';    
            y = bsxfun(@rdivide,exp(psi),sum(exp(psi),2));
            
            ClassifierResults = dataSet.setObservations(y);
        end
    end
end
