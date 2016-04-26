% prtBrvMvbHierarchy - PRT BRV MVB Hierarchical model structure
%   Has parameters that specify a collection of Beta densities









classdef prtBrvMvbHierarchy

    properties
        countOfOnes = [];
        countOfZeros = [];
    end
    
    methods
        function obj = prtBrvMvbHierarchy(varargin)
            if nargin < 1
                return
            end
            obj = defaultParameters(obj,varargin{1});
        end
        function obj = defaultParameters(obj, nDimensions)
            obj.countOfZeros = 0.5*ones(1,nDimensions);
            obj.countOfOnes = 0.5*ones(1,nDimensions);
        end
        
        function tf = isValid(self)
            tf = ~isempty(self.countOfZeros);
        end
    end
end
