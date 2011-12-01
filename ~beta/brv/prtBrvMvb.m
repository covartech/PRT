% PRTBRVMVB - PRT BRV Multivariate Binary Observation Model
%
% Constructor takes the dimesionality
%
% Impliments all abstract properties and methods from prtBrvObsModel.
%
% Additional Properties:
%   model - prtBrvMvbHierarchy object that contains the parameters of the
%       prior/posterior
% Additional Hidden Properties:
%   initFuzzyFactor - Used to weaken the results of kmeans in the
%       mixture initialization process. Between 0 and 1 (inclusivly) and
%       probably greater than 0.9. Default 1.
%   initModifiyPrior - Specifies weather to modify the covariance of the
%       prior to more closely match that of the training data during
%       mixture initialization.
%
% Also inherits from prtBrvVbOnlineObsModel and therefore impliments
%   vbOnlineWeightedUpdate

classdef prtBrvMvb < prtBrvObsModel & prtBrvVbOnlineObsModel
    
    properties (SetAccess = private)
        name = 'Multi-varite Binary Bayesian Random Variable';
        nameAbbreviation = 'BRVMVB';
    end
    
    properties (SetAccess = protected)
        isSupervised = false;
        isCrossValidateValid = true;
    end
    
    properties
        model = prtBrvMvbHierarchy;
    end    
    
    properties (Hidden)
        initFudgeFactor = 1; % Between zero and 1, probably > 0.9
    end
    
    methods
        function obj = prtBrvMvb(varargin)
            if nargin < 1
                return
            end
            obj.model = prtBrvMvbHierarchy(varargin{1});
        end
        
        function val = nDimensions(obj)
            val = length(obj.model.countOfOnes);
        end
        
        function y = conjugateVariationalAverageLogLikelihood(obj, x)

            [logProb0, logProb1] = obj.expectedValueLogProbabilities;
            
            y = sum(bsxfun(@times,x,logProb1) + bsxfun(@times,~x,logProb0),2);
        end
        
        function [phiMat, priorObjs] = mixtureInitialize(objs, priorObjs, X) % Vector of objects
            
            learningInitialMembershipFactor = objs(1).initFudgeFactor;
            
            [classMeans,kmMembership] = prtUtilKmeans(X,length(objs),'handleEmptyClusters','random','distanceMetricFn',@prtDistanceHamming,'maxIterations',100,'logicalMeans',true); %#ok<ASGLU>
            
            phiMat = zeros(size(X,1),length(objs));
            for iComp = 1:length(objs)
                phiMat(kmMembership == iComp, iComp) = learningInitialMembershipFactor;
            end
            phiMat(phiMat==0) = (1-learningInitialMembershipFactor)./(length(objs)-1);
            
            % We should normalize this just in case the
            % learningInitialMembershipFactor was set poorly
            phiMat = bsxfun(@rdivide,phiMat,sum(phiMat,2));
        
        end
        
        function obj = weightedConjugateUpdate(obj, priorObj, x, weights)
            if nargin < 4 || isempty(weights)
                weights = ones(size(x,1),1);
            end
            
            obj.model.countOfOnes = sum(bsxfun(@times,x,weights)) + priorObj.model.countOfOnes;
            
            obj.model.countOfZeros = sum(bsxfun(@times,~x,weights)) + priorObj.model.countOfZeros;
            
        end
        
        function kld = conjugateKld(obj, priorObj)

            betaKlds = zeros(1,length(obj.model.countOfOnes));
            for iDim = 1:length(obj.model.countOfOnes)
                betaKlds(iDim) = prtRvUtilDirichletKld([obj.model.countOfZeros(iDim) obj.model.countOfOnes(iDim)],[priorObj.model.countOfZeros(iDim) priorObj.model.countOfOnes(iDim)]);
            end
            
            kld = sum(betaKlds);
        end
        
        function x = posteriorMeanDraw(obj, n, varargin)
            if nargin < 2
                n = 1;
            end
            modelMean.probabilities = obj.posteriorMeanStruct();
            x = bsxfun(@gt,rand(n,length(modelMean.probabilities)),modelMean.probabilities);
        end
        
        function s = posteriorMeanStruct(obj)
            s.probabilities = obj.model.countOfOnes./obj.model.countOfZeros;
        end
        
        function model = modelDraw(obj)
            model.probabilities = zeros(1,length(obj.model.countOfOnes));
            for iDim = 1:length(obj.model.countOfOnes)
                model.probabilities(iDim) = prtRvUtilDirichletRnd([obj.model.countOfZeros(iDim) obj.model.countOfOnes(iDim)]);
            end
        end
        
        function plot(objs,colors)
            
            nComponents = length(objs);
            
            if nargin < 2
                colors = prtPlotUtilClassColors(nComponents);
            end
            
            countOfOnesMat = cell2mat(arrayfun(@(c)c.model.countOfOnes,objs,'uniformOutput',false));
            countOfZerosMat = cell2mat(arrayfun(@(c)c.model.countOfZeros,objs,'uniformOutput',false));
            
            probMat = countOfOnesMat ./ (countOfOnesMat + countOfZerosMat);
            
            h = plot(probMat');
            
            for iLine = 1:length(h)
                set(h(iLine),'color',colors(iLine,:));
            end
            title('Posterior Mean Probabilities')
            ylim([0 1])
            xlim([1 size(probMat,2)])
            
        end
        
        function [obj, training] = vbOnlineWeightedUpdate(obj, priorObj, x, weights, lambda, D, prevObj)
            S = size(x,1);
            
            if nargin < 4 || isempty(weights)
                weights = ones(size(x,1),1);
            end
            
            obj.model.countOfOnes = (D/S*sum(bsxfun(@times,x,weights)) + priorObj.model.countOfOnes)*lambda + prevObj.model.countOfOnes*(1-lambda);
            obj.model.countOfZeros = (D/S*sum(bsxfun(@times,~x,weights)) + priorObj.model.countOfZeros)*lambda + prevObj.model.countOfZeros*(1-lambda);
            
            training = struct([]);
        end
        
        function [logProb0, logProb1] = expectedValueLogProbabilities(obj)
            psi1 = psi(obj.model.countOfOnes);
            psi0 = psi(obj.model.countOfZeros);

            psiSum = psi(obj.model.countOfOnes+obj.model.countOfZeros);
            
            logProb1 = psi1 - psiSum;
            logProb0 = psi0 - psiSum;
            %normalizer = prtUtilSumExp(cat(1,logProb0,logProb1));
            %logProb0 = logProb0-normalizer;
            %logProb1 = logProb1-normalizer;
        end
    end
end