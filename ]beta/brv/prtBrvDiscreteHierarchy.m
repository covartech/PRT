% PRTBRVDISCRETEHIERARCHY - PRT BRV Discrete hierarchical model structure
%   Has parameters that specify a dirichlet density





classdef prtBrvDiscreteHierarchy

    properties
        lambda
    end
    methods
        function self = prtBrvDiscreteHierarchy(varargin)
            if nargin < 1
                return
            end
            
            self = defaultParameters(self,varargin{1});
        end
        
        function self = defaultParameters(self, nDimensions)
            self.lambda = ones(1,nDimensions)/nDimensions;
            %self.lambda = ones(1,nDimensions)*nDimensions;
        end
        
        function tf = isValid(self)
            tf = ~isempty(self.lambda);
        end
    end
end
