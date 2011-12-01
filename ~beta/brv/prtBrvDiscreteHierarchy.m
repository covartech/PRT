% PRTBRVDISCRETEHIERARCHY - PRT BRV Discrete hierarchical model structure
%   Has parameters that specify a dirichlet density
classdef prtBrvDiscreteHierarchy
    properties
        lambda
    end
    methods
        function obj = prtBrvDiscreteHierarchy(varargin)
            if nargin < 1
                return
            end
            obj.lambda = ones(1,varargin{1})/varargin{1};
        end
    end
end