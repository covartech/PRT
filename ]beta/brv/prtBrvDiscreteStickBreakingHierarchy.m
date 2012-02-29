% PRTBRVDISCRETEHIERARCHY - PRT BRV Discrete hierarchical model structure
%   Has parameters that specify a dirichlet density
classdef prtBrvDiscreteStickBreakingHierarchy
    properties
        sortingInds
        unsortingInds
    end
    properties
        alphaGammaParams = [1e-6 1e-6];
        counts = [];
        beta = [];
    end
    properties (Hidden = true)
        useGammaPriorOnScale = true;
        useOptimalSorting = true;
    end
    properties (Dependent, SetAccess='private')
        truncationLevel
        expectedValueLogStickLengths
        expectedValueLogOneMinusStickLengths
        expectedValueLogProbabilities
        posteriorMean
        expectedValueAlpha
    end
    
    methods
        function obj = prtBrvDiscreteStickBreakingHierarchy(varargin)
            if nargin < 1
                return
            end
            
            truncationLevel = varargin{1};
            
            % Initialize beta
            obj.counts = zeros(truncationLevel,1);
            obj.beta = ones(truncationLevel,2);
            obj.beta(:,2) = obj.alphaGammaParams(1)/obj.alphaGammaParams(2);
            obj.sortingInds = (1:truncationLevel)';
            obj.unsortingInds = obj.sortingInds;
        end
        
        function pis = draw(obj)
             
            
             vs = zeros(obj.truncationLevel,2);
             for iV = 1:obj.truncationLevel
                 vs(iV,:) = prtRvUtilDirichletDraw([obj.beta(iV,1),obj.beta(iV,2)]);
             end
             vs = vs(:,1);
             
             pis = zeros(obj.truncationLevel,1);
             for iPi = 1:length(vs)
                 if iPi == 1
                     pis(iPi) = vs(iPi);
                 else
                     pis(iPi) = exp(log(vs(iPi))+sum(log(1-vs(1:(iPi-1)))));
                 end
             end
             
             pis(end) = 1-sum(pis(1:end-1));
             pis(pis<0) = 0; % This happens in the range of eps sometimes.
             
             pis = pis./sum(pis);
        end
        
        function obj = conjugateUpdate(obj,priorObj,counts)
            
            counts = counts(:);
            
            if obj.useOptimalSorting
                [counts, obj.sortingInds] = sort(counts,'descend');
                [dontNeed, obj.unsortingInds] = sort(obj.sortingInds,'ascend'); %#ok<ASGLU>
            else
                obj.sortingInds = (1:obj.truncationLevel)';
                obj.unsortingInds = obj.sortingInds;
            end
            sumIToK = flipud(cumsum(flipud(counts)));
            sumIPlus1ToK = sumIToK-counts;
            
            if obj.useOptimalSorting
                obj.counts = counts(obj.unsortingInds);
                sumIPlus1ToK = sumIPlus1ToK(obj.unsortingInds);
            else
                obj.counts = counts;
            end
            
            % Update stick parameters
            obj.beta(:,1) = obj.counts + priorObj.beta(:,1);
            obj.beta(:,2) = sumIPlus1ToK + priorObj.beta(:,2) + obj.expectedValueAlpha;
            
            % Update alpha Gamma density parameters
            if obj.useGammaPriorOnScale
                obj.alphaGammaParams(1) = priorObj.alphaGammaParams(1) + obj.truncationLevel - 1;
                eLog1MinusVt = obj.expectedValueLogOneMinusStickLengths;
                obj.alphaGammaParams(2) = priorObj.alphaGammaParams(2) - sum(eLog1MinusVt(isfinite(eLog1MinusVt))); % Sometimes there are -infs at the end
            end
        end
        function kld = kld(obj, priorObj)
            if obj.useGammaPriorOnScale
                % These beta KLDs are not correct. Really we need to take
                % the expected value of the KLDs over the alpha Gamma
                % density. This is diffucult. Here we use an approximation
                % that may cause a decrease in NFE near convergence.
                betaKlds = zeros(obj.truncationLevel,1);
                for iV = 1:obj.truncationLevel
                    betaKlds(iV) = prtRvUtilDirichletKld(obj.beta(iV,:),priorObj.beta(iV,:));
                end
                
                alphaKld = prtRvUtilGammaKld(obj.alphaGammaParams(1),obj.alphaGammaParams(2),priorObj.alphaGammaParams(1),priorObj.alphaGammaParams(2));
                
                kld = sum(betaKlds) + alphaKld;
            else
                betaKlds = zeros(obj.truncationLevel,1);
                for iV = 1:obj.truncationLevel
                    betaKlds(iV) = prtRvUtilDirichletKld(obj.beta(iV,:),priorObj.beta(iV,:));
                end
                kld = sum(betaKlds);
            end
        end
        
        function [obj, training] = vbOnlineWeightedUpdate(obj, priorObj, x, weights, lambda, D, prevObj) %#ok<INUSL>
            S = size(x,1);
            
            if ~isempty(weights)
                x = bsxfun(@times,x,weights);
            end
            
            localCounts = x(:);
            
            if obj.useOptimalSorting
                [localCounts, obj.sortingInds] = sort(localCounts,'descend');
                [dontNeed, obj.unsortingInds] = sort(obj.sortingInds,'ascend'); %#ok<ASGLU>
            else
                obj.sortingInds = (1:obj.truncationLevel)';
                obj.unsortingInds = obj.sortingInds;
            end
            
            sumIToK = flipud(cumsum(flipud(localCounts)));
            sumIPlus1ToK = sumIToK-localCounts;
            
            if obj.useOptimalSorting
                obj.counts = localCounts(obj.unsortingInds);
                sumIPlus1ToK = sumIPlus1ToK(obj.unsortingInds);
            else
                obj.counts = localCounts;
            end
            
            % Update stick parameters
            updatedBeta = zeros(obj.truncationLevel,2);
            
            updatedBeta(:,1) = D/S*obj.counts + priorObj.beta(:,1);
            updatedBeta(:,2) = D/S*sumIPlus1ToK + priorObj.beta(:,2) + obj.expectedValueAlpha;
            
            obj.beta = updatedBeta*lambda + (1-lambda)*prevObj.beta;
            
            if obj.useGammaPriorOnScale
                obj.alphaGammaParams(1) = priorObj.alphaGammaParams(1) + obj.truncationLevel - 1;
                eLog1MinusVt = obj.expectedValueLogOneMinusStickLengths;
                obj.alphaGammaParams(2) = priorObj.alphaGammaParams(2) - sum(eLog1MinusVt(isfinite(eLog1MinusVt))); % Sometimes there are -infs at the end
            end
            
            training = struct([]);
        end
    end
    methods
        function val = get.expectedValueLogStickLengths(obj)
            val = psi(obj.beta(:,1)) - psi(sum(obj.beta,2));
        end
        function val = get.expectedValueLogOneMinusStickLengths(obj)
            val = psi(obj.beta(:,2)) - psi(sum(obj.beta,2));
        end
        function val = get.expectedValueLogProbabilities(obj)
            expectedLogOneMinusStickLengths = obj.expectedValueLogOneMinusStickLengths;
            expectedLogOneMinusStickLengths = expectedLogOneMinusStickLengths(obj.sortingInds);
            
            val = obj.expectedValueLogStickLengths(obj.sortingInds) + cat(1,0,cumsum(expectedLogOneMinusStickLengths(1:end-1)));
            
            val = val(obj.unsortingInds);
            
        end
        function val = get.posteriorMean(obj)
            val = exp(obj.expectedValueLogProbabilities);
        end
        function val = get.truncationLevel(obj)
            val = size(obj.beta,1);
        end
        function val = get.expectedValueAlpha(obj)
            
            alphaParams = obj.alphaGammaParams;
            if length(alphaParams) < 2
                alphaParams = cat(2,1,alphaParams);
            end
            
            val = alphaParams(2)./alphaParams(1);
        end
    end
end


