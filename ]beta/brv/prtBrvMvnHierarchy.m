% PRTBRVMVNHIERARCHY - PRT BRV MVN Hierarchical model structure
%   Has parameters that specify a Normal-Inverse-Wishart Density
classdef prtBrvMvnHierarchy
    properties
        meanMean
        meanBeta
        covPhi
        covNu
    end
    
    methods
        function self = prtBrvMvnHierarchy(varargin)
            if nargin < 1
                return
            end
            self = defaultParameters(self,varargin{1});
        end
        
        function self = defaultParameters(self, nDimensions)
            self.meanMean = zeros(1,nDimensions);
            self.meanBeta = nDimensions;
            self.covNu = nDimensions;
            self.covPhi = eye(nDimensions)*self.covNu;
        end
        
        function tf = isValid(self)
            tf = ~isempty(self.meanMean);
        end
    end
end