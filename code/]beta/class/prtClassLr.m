classdef prtClassLr < prtClass

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


    properties (SetAccess=private)
        name = 'Logistic Regression'; % Logistic Regression
        nameAbbreviation = 'LR' % LR
        isNativeMary = true;  % True
    end
    
    properties (SetAccess = protected)
        % wMat  
        %   wMat is a DataSet.nDimensions by DataSet.nClasses matrix of
        %   projection weights learned during train(dataSet)
        %   wMat is a DataSet.nDimensions + 1 by DataSet.nClasses matrix if
        %   Obj.includeBias is true
        wMat = [];  % Regression weights
        
        % nIterations
        %   Number of iterations used in training.  This is set to a number
        %   between 1 and maxIter during training.
        nIterations = nan;  % The number of iterations used in training
        
        % converged
        %   logical set during learned during train(dataSet) if
        %   optimization converged before the maximum number of iterations
        %   is reached
        converged = false;
    end
    
    properties
        % includeBias
        %   logical that specifies to include a bias term in the regression
        includeBias = true;
        
        % wChangeTolerance
        %   threshold of change in regresion weights to consider learning
        %   converged
        wChangeTolerance = 1e-3;
        
        % nMaxItertaions
        %   Maximum number of iterations to allow before exiting without
        %   convergence.
        nMaxIterations = 500;  % Maxmimuum number of iterations
    end
    
    methods
        function self = prtClassLr(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function self = set.nMaxIterations(self,val)
            if ~prtUtilIsPositiveScalarInteger(val)
                error('prt:prtClassLr:nMaxIterations','nMaxIterations must be a positive scalar integer');
            end
            self.nMaxIterations = val;
        end
        
        function self = set.wChangeTolerance(self, val)
            if ~prtUtilIsPositiveScalar(val)
                error('prt:prtClassLr:wChangeTolerance','wChangeTolerance must be a positive scalar');
            end
            self.wChangeTolerance = val;
        end
        
        function self = set.includeBias(self, val)
            if ~prtUtilIsLogicalScalar(val)
                error('prt:prtClassLr:includeBias','includeBias must be a logical scalar');
            end
            self.includeBias = val;
        end        
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            %self = trainAction(self,dataSet)
            
            [self, x] = getFeatureMapTrain(self, dataSet);
            
            y = dataSet.getTargetsAsBinaryMatrix;
            nClasses = dataSet.nClasses;
            d = size(x,2);
            
            % Random initialization; last set of weights is set to 0
            weightMatrix = randn(nClasses-1,d);
            weightMatrix = cat(1,weightMatrix,zeros(1,size(weightMatrix,2)));
            weightMatrixOld = weightMatrix;
            
            %Can calculate B matrix outside loop; makes life fast
            xx = x'*x;
            B = kron(-1/2*(eye(nClasses-1)-ones(nClasses-1)/dataSet.nClasses),xx);
            
            self.converged = false;
            %visitProb = ones(size(w
            
            % Log prediction
            psi = (weightMatrix*x')';
            % Log safe method of normalization
            py = exp(bsxfun(@minus,psi,prtUtilSumExp(psi')'));
            % Non log safe method, potential underflow
            % py = bsxfun(@rdivide,exp(psi),sum(exp(psi),2));   
            
            
            useComponentWiseWeightUpdates = (d*nClasses).^2 > size(x,1);
            
            
            
            if useComponentWiseWeightUpdates
                scheduleGeometricProb = 0.99;
                
                for iter = 1:self.nMaxIterations
                
                    for k = 1:size(weightMatrix,2)
                        
                        if all(weightMatrix(:,k)==0) && rand > scheduleGeometricProb^(iter-1);
                            % Don't update zero weights 
                            % with a random probability geometrically
                            % distributed with iteration
                            continue
                        end
                        
                        % Current label error
                        yError = y-py;
                        
                        % Weight gradient for dimension k
                        gk = sum(bsxfun(@times,yError,x(:,k)))';
                        gk = gk(1:(nClasses-1));
                        
                        for iClass = 1:(nClasses-1)
                            cBInd =(iClass-1)*size(x,2) + k;
                            % Update only this weight
                            weightMatrix(iClass,k) = self.updateWeight(weightMatrix(iClass,k), gk(iClass), B(cBInd,cBInd));
                        end
                        
                        % Given this new update we need to update the new psi
                        psi = psi - (weightMatrixOld(:,k)*x(:,k)')' + (weightMatrix(:,k)*x(:,k)')';
                        
                        % py = exp(bsxfun(@minus,psi,prtUtilSumExp(psi')'));
                        py = exp(psi);
                        py = bsxfun(@rdivide,py,sum(py,2));
                        
                    end
                    
                    if self.convergenceDistanceMetric(weightMatrix(1:(end-1),:),weightMatrixOld(1:(end-1),:)) < self.wChangeTolerance
                        self.converged = true;
                        break;
                    end
                    weightMatrixOld = weightMatrix;
                    
                end
            else
                Binv = inv(B);
                
                kronIndex1 = repmat(1:size(y,2),size(x,2),1);
                kronIndex2 = repmat(1:size(x,2),1,size(y,2));
                xRepmat = x(:,kronIndex2);
                
                % Batch updating
                for iter = 1:self.nMaxIterations
                    yError = y-py;
                        
                    % Weight gradient
                    g = sum(yError(:,kronIndex1(:)).*xRepmat);
                    g = g(:);
                    
                    weightMatrix = self.updateWeightsBatch(weightMatrix, g, B, Binv);
                        
                    psi = (weightMatrix*x')';
                        
                    py = exp(bsxfun(@minus,psi,prtUtilSumExp(psi')'));
                    
                    if self.convergenceDistanceMetric(weightMatrix(1:(end-1),:),weightMatrixOld(1:(end-1),:)) < self.wChangeTolerance
                        self.converged = true;
                        break;
                    end
                    
                    weightMatrixOld = weightMatrix;
                    
                end
            end
                
            self.wMat = weightMatrix;
        end
        
        function ClassifierResults = runAction(self,dataSet)
            %ClassifierResults = runAction(self,DataSet)
            
            x = getFeatureMapRun(self, dataSet);
            
            assert(size(x,2)==size(self.wMat,2),'Incorect dimensionality for this prtClassLr object. Perhaps the value of includeBias has changed between train() and run()')
            
            psi = (self.wMat*x')';    
            
            ClassifierResults = dataSet.setObservations(exp(bsxfun(@minus,psi,prtUtilSumExp(psi')')));
        end
    end
    methods (Hidden)
        
        function [self, x] = getFeatureMapTrain(self, dataSet)
            x = dataSet.getObservations;
            
            if self.includeBias
                x = cat(2,ones(size(x,1),1),x); %DC component
            end
        end
       
        function x = getFeatureMapRun(self, dataSet)
            [self, x] = getFeatureMapTrain(self, dataSet); %#ok<ASGLU>
        end
        
        function newWeight = updateWeight(self, weight, g, B)
            newWeight = weight - g./B;
        end
        
        function weights = updateWeightsBatch(self, weights, g, B, Binv)
            weights(1:(end-1),:) = weights(1:(end-1),:) - reshape(Binv*g(1:((size(weights,1)-1)*size(weights,2))),[size(weights,2), size(weights,1)-1])';
        end
        
        function d = convergenceDistanceMetric(self, weights, weightsOld)
            d = max((weights(:)-weightsOld(:)).^2);
            %d = norm(weights(:)-weightsOld(:))/numel(weightMatrix);
        end
    end
end
