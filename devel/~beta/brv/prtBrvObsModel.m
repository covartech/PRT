% PRTBRVOBSMODEL - PRT BRV Observation Model object
% Abstract Propeties:
%   name
% Properties
%   userData
% Abstract Methods:
%   conjugateVariationalAverageLogLikelihood - Evaluates the log expect 
%       likelihood using the conjugate density, with parameters determined
%       by the object
%   mixtureInitialize - Determined initial membership matrix for a 
%       collection of prtBrvObsModels
%   weightedConjugateUpdate - Determine the parameters of the
%       posterior density using weighting on each sample
%   conjugateKld - Kullback-Leibler distance between the conjugate
%       densities of two prtBrv objects
%   posteriorMeanDraw - Draw from the observation model using the
%       the mean posterior parameters
%   posteriorMeanStruct - Convert the posterior density to a structure with
%       the mean parameters
%   modelDraw - Draw from the parameters of an MVN observation from the
%       current hierarchical model.
% Methods:
%   conjugateUpdate - Determine the parameters of the posterior density
%       using the specified samples. Calls weightedConjugateUpdate with
%       weights all equal to one.

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
        plot(objs,colors)
        x = posteriorMeanDraw(obj, n, varargin)
        s = posteriorMeanStruct(obj)
        model = modelDraw(obj)
    end
    methods
        function obj = conjugateUpdate(obj, prior, x)
            obj = weightedConjugateUpdate(obj, prior, x, ones(size(x,1),1));
        end
    end
end