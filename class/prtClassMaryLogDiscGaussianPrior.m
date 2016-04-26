classdef prtClassMaryLogDiscGaussianPrior < prtClassMaryLogDisc







    
    properties (SetAccess=private)
    end
    
    properties (SetAccess = protected)
        % Lambda
        lambda = .01;  %weak prior, \lambda \propto 1/\sigma
    end
    
    methods
        
        function self = prtClassMaryLogDiscGaussianPrior(varargin)
            
            self = prtUtilAssignStringValuePairs(self,varargin{:});
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
            BinvLambdaI = (B-self.lambda*eye(size(B)))^-1;
            BinvLambdaIB = BinvLambdaI*B;
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
                
                wVec = weightMatrix(1:end-1,:)';
                wVec = wVec(:);
                wVec = BinvLambdaIB*wVec(1:numWeights) - BinvLambdaI*g(1:numWeights);
                weightMatrix(1:end-1,:) = reshape(wVec,size(weightMatrix(1:end-1,:),2),size(weightMatrix(1:end-1,:),1))';
                
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
