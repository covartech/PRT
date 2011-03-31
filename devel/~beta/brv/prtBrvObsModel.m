classdef prtBrvObsModel < prtBrv
    properties (Abstract)
        name
    end
    properties
        userData = [];
    end
    methods (Abstract)
        y = conjugateVariationalAverageLogLikelihood(obj, x)
        [phiMat, priorObjs] = mixtureInitialize(objs, priorObjs, x)
        obj = weightedConjugateUpdate(obj, priorObj, x, weights)
        kld = conjugateKld(obj, priorObj)
        plot(objs)
        x = posteriorMeanDraw(obj, n, varargin)
        s = posteriorMeanStruct(obj)
    end
    methods
        function obj = conjugateUpdate(obj, prior, x)
            obj = weightedConjugateUpdate(obj, prior, x, ones(size(x,1),1));
        end
    end
end