classdef prtBrvMultipleInstanceMixturesVbTraining





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
         nSamplesPerComponentH1 = [];
         
         iterations = struct('negativeFreeEnergy',[],'eLogLikelihood',[],'kld',[]);
         negativeFreeEnergy = -inf;
         previousNegativeFreeEnergy = nan;
         eLogLikelihood = [];
         kld = [];

         componentTraining = prtBrvMixtureVbTraining;
         bagInds = [];
         clusterIsCertainH0 = [];
    end
    
    methods
        function self = prtBrvMultipleInstanceMixturesVbTraining(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end    
end
