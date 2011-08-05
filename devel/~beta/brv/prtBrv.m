% PRTBRV - PRT Bayesian Random Variable Class
%   Abstract Methods:
%       nDimensions

classdef prtBrv < prtAction
    methods (Abstract)
        val = nDimensions(obj)
    end
end