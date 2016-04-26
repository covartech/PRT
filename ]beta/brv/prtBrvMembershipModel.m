classdef prtBrvMembershipModel





    methods (Abstract)

        [phiMat, priorVec] = collectionInitialize(selfVec, priorVec, x)
        self = weightedConjugateUpdate(self, prior, x, weights)
        self = conjugateUpdate(self, prior, x)
    end
end
