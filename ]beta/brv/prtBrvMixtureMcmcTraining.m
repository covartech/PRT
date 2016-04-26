classdef prtBrvMixtureMcmcTraining





    properties

         randnState = randn('seed'); 
         randState = rand('seed');
         startTime = now;
         endTime = [];
         
         membershipModels
         componentMemberships
         componentLogLikelihoods
         componentLogLikelihoodsInModel
         
         iterations = struct('logLikelihood',[]);
    end
    methods
        function self = prtBrvMixtureVbTraining(varargin)
            self = prtBrvMixtureMcmcTraining(self,varargin{:});
        end
    end    
end
