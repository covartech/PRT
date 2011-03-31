classdef prtBrvDiscretePrior
    properties
        lambda
    end
    
    methods
        function obj = prtBrvDiscretePrior(varargin)
            if nargin < 1
                return
            end
            obj.lambda = ones(1,varargin{1})/varargin{1};
        end
    end
end