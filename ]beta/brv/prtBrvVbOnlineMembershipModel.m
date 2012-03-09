classdef prtBrvVbOnlineMembershipModel
    methods (Abstract)
        [self, training] = vbOnlineWeightedUpdate(self, prior, x, weights, lambda, D, prev);
    end
end