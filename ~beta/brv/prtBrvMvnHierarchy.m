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
        function obj = prtBrvMvnHierarchy(varargin)
            if nargin < 1
                return
            end
            obj = defaultParameters(obj,varargin{1});
        end
        function obj = defaultParameters(obj, nDimensions)
            obj.meanMean = zeros(1,nDimensions);
            obj.meanBeta = nDimensions;
            obj.covNu = nDimensions;
            obj.covPhi = eye(nDimensions)*obj.covNu;
        end
    end
end