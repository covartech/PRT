classdef prtBrvHmm < prtBrv
    properties
        
    end
    methods
        function obj = prtBrvHmm(varargin)
            if nargin < 1
                return
            end
            obj.model = prtBrvHmmPrior(varargin{:});
        end
    end
end