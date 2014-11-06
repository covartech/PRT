classdef prtClassMaryLogDiscSparse < prtClassMaryLogDisc

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
    end
    
    properties (SetAccess = protected)
        % Lambda
        lambda = 10;  %weak prior, \lambda \propto 1/\sigma
    end
    
    methods
        
        function self = prtClassMaryLogDiscSparse(varargin)
            
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
            
            for j = 1:self.maxIter
                for k = 1:numWeights
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
                    wVec(k) = prtUtilSoft(wVec(k)-g(k)/B(k,k),-self.lambda./B(k,k));
                    weightMatrix(1:end-1,:) = reshape(wVec,size(weightMatrix(1:end-1,:),2),size(weightMatrix(1:end-1,:),1))';
                    disp(weightMatrix)
                    pause;
                end
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
