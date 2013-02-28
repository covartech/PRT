classdef prtClassLrs < prtClassLr

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


    properties
        % Lambda
        lambda = 10;  %weak prior, \lambda \propto 1/\sigma
    end    
    
    methods
        function self = prtClassLrs(varargin)
            self = self@prtClassLr();
            self = prtUtilAssignStringValuePairs(self,varargin{:});
            
            %self.name = 'Logistic Regression, Sparse'; % Logistic Regression, Sparse
            %self.nameAbbreviation = 'LRS'; % LRS
        end
    end
    
    methods (Hidden)
        function newWeight = updateWeight(self, weight, g, B)
            
            newWeight = prtUtilSoft(weight-g./B,-self.lambda./B);
            
        end
        
        function weights = updateWeightsBatch(self, weights, g, B, Binv)
            weightsVec = weights(1:end-1,:)';
            weightsVec = weightsVec(:);
            
            w = sqrt(abs(weightsVec));
            newWeights = bsxfun(@times,bsxfun(@times,w,inv(bsxfun(@times,bsxfun(@times,w,B),w')-self.lambda*eye(size(B)))),w')*(B*weightsVec - g(1:length(weightsVec)));
                        
            weights(1:(end-1),:) = reshape(newWeights,[size(weights,2) size(weights,1)-1])';
        end
        
    end
end
