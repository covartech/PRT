classdef prtBrvMixtureVbTraining





    properties

         randnState = randn('seed'); 
         randState = rand('seed');
         startTime = now;
         endTime = [];
         nIterations = 0;
         
         variationalLogLikelihoodBySample = [];
         variationalClusterLogLikelihoods = [];
         componentMemberships = [];
         nSamplesPerComponent = [];
         
         iterations = struct('negativeFreeEnergy',[],'eLogLikelihood',[],'kld',[]);
         negativeFreeEnergy = -inf;
         previousNegativeFreeEnergy = nan;
         eLogLikelihood = [];
         kld = [];
    end
    methods
        function self = prtBrvMixtureVbTraining(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end    
end
