classdef prtBrvVbOnlineObsModel
    methods (Abstract)
        [obj, training] = vbOnlineWeightedUpdate(obj, x, weights, lambda, D);
    end
end