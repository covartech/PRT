classdef prtClassLrs < prtClassLr







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
