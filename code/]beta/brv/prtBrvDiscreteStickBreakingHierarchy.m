% PRTBRVDISCRETEHIERARCHY - PRT BRV Discrete hierarchical model structure
%   Has parameters that specify a dirichlet density

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.
classdef prtBrvDiscreteStickBreakingHierarchy

    properties
        sortingInds
        unsortingInds
    end
    properties
        alphaGammaParams = [1 1]; % These are the prior parameters of
                                     % the gamma density if
                                     % useGammaPriorOnScale is true
                                     % Otherwise the ratio of these
                                     % alphaGammaParams(2)/alphaGammaParams(1)
                                     % is set as the certain alpha
                                     % Alternatively if
                                     % useGammaPriorOnScale is false this
                                     % can be set to a scalar
        counts = []; % This is the data stored in the object
        beta = []; % These are parameters of each of the beta distributions
    end
    properties (Hidden = true)
        useGammaPriorOnScale = true;
        gammaUpdateIterations = 10; % When using a gamma prior on alpha we iterate through the stick update this many times. This speeds convergence.
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
        function self = prtBrvDiscreteStickBreakingHierarchy(varargin)
            if nargin < 1
                return
            end
            self = defaultParameters(self,varargin{1});
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
            
            if obj.useGammaPriorOnScale
                for iUpdate = 1:obj.gammaUpdateIterations;
                    % Update stick parameters
                    obj.beta(:,1) = obj.counts + priorObj.beta(:,1);
                    obj.beta(:,2) = sumIPlus1ToK + (priorObj.beta(:,2) - priorObj.expectedValueAlpha) + obj.expectedValueAlpha;
                    % Because both the prior and the posterior share the same alpha we don't need to add it in twice.
                    % We remove it from the prior in the case that we have a gamma
                    % prior on the scale
                    
                    % Update alpha Gamma density parameters
                    if obj.useGammaPriorOnScale
                        obj.alphaGammaParams(1) = priorObj.alphaGammaParams(1) + obj.truncationLevel - 1;
                        eLog1MinusVt = obj.expectedValueLogOneMinusStickLengths;
                        eLog1MinusVt(~isfinite(eLog1MinusVt)) = 0; % Sometimes there are -infs at the end
                        obj.alphaGammaParams(2) = priorObj.alphaGammaParams(2) - sum(eLog1MinusVt);
                    end
                end
            end
            
            % Update stick parameters
            obj.beta(:,1) = obj.counts + priorObj.beta(:,1);
            obj.beta(:,2) = sumIPlus1ToK + (priorObj.beta(:,2) - priorObj.expectedValueAlpha) + obj.expectedValueAlpha;
            % Because both the prior and the posterior share the same alpha we don't need to add it in twice.
            % We remove it from the prior in the case that we have a gamma
            % prior on the scale
            
        end
        
        function kld = kld(obj, priorObj)
            if obj.useGammaPriorOnScale
                % These beta KLDs are not correct. Really we need to take
                % the expected value of the KLDs over alpha's Gamma
                % density. This is diffucult. Here we use an approximation
                % that may cause a decrease in NFE near convergence.
                % We just assume that we can plug in the expected value of
                % alpha everywhere into the standard Beta KLD
                betaKlds = zeros(obj.truncationLevel,1);
                for iV = 1:obj.truncationLevel
                    cPost = obj.beta(iV,:);
                    
                    cPrior = priorObj.beta(iV,:);
                    cPrior(:,2) = cPrior(:,2) - priorObj.expectedValueAlpha + obj.expectedValueAlpha;
                    
                    betaKlds(iV) = prtRvUtilDirichletKld(cPost,cPrior);
                end
                
                alphaKld = prtRvUtilGammaKld(obj.alphaGammaParams(1),obj.alphaGammaParams(2),priorObj.alphaGammaParams(1),priorObj.alphaGammaParams(2));
                
                kld = sum(betaKlds) + alphaKld;
                
                %sum(betaKlds)
                %alphaKld
                
            else
                betaKlds = zeros(obj.truncationLevel,1);
                for iV = 1:obj.truncationLevel
                    cPrior = priorObj.beta(iV,:);
                    cPrior(:,2) = cPrior(:,2)-priorObj.expectedValueAlpha+obj.expectedValueAlpha;
                    
                    betaKlds(iV) = prtRvUtilDirichletKld(obj.beta(iV,:),cPrior);
                end
                kld = sum(betaKlds);
            end
        end
        
        function [obj, training] = vbOnlineWeightedUpdate(obj, priorObj, x, weights, lambda, D, prevObj) 
            S = size(x,1);
            
            if ~isempty(weights)
                x = bsxfun(@times,x,weights);
            end
            
            localCounts = sum(x,1)';
            
            obj.counts = D/S*localCounts*lambda + (1-lambda)*prevObj.counts + priorObj.counts; % Counts must be updated as a mixture of the prev and the local
            
            if obj.useOptimalSorting
                [~, obj.sortingInds] = sort(obj.counts,'descend'); % We need to sort based on the the updated counts
                [dontNeed, obj.unsortingInds] = sort(obj.sortingInds,'ascend'); %#ok<ASGLU>
            else
                obj.sortingInds = (1:obj.truncationLevel)';
                obj.unsortingInds = obj.sortingInds;
            end
            
            % Update stick parameters
            % To calculate sumIPlus1ToK we sort before we cumsum. Then we
            % unsort the result so that the beta matrix is actually
            % unsorted.
            localCountsSorted = localCounts(obj.sortingInds); % Sort the local counts according to the order of the blended counts
            sumIToK = flipud(cumsum(flipud(localCountsSorted)));
            sumIPlus1ToK = sumIToK-localCountsSorted;
            sumIPlus1ToK = sumIPlus1ToK(obj.unsortingInds);
            
            % We have to sort the previous object the same we that we sort
            % the current object for the purpos of calculating sumIPlus1ToK
            prevCountsSorted = prevObj.counts(obj.sortingInds); % We need to sort the previous counts the same as our current counts are sorted
            prevSumIToK = flipud(cumsum(flipud(prevCountsSorted)));
            prevSumIPlus1ToK = prevSumIToK - prevCountsSorted;
            prevSumIPlus1ToK = prevSumIPlus1ToK(obj.unsortingInds);
            
            % the beta matrix is now totally unsorted but the sorting is
            % done relative to the updated counts
            obj.beta(:,1) = D/S*localCounts*lambda + (1-lambda)*prevObj.counts + priorObj.beta(:,1);
            obj.beta(:,2) = D/S*sumIPlus1ToK*lambda + (1-lambda)*prevSumIPlus1ToK + priorObj.beta(:,2) + obj.expectedValueAlpha;
            
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
            expctedValueStickLengths = obj.beta(:,1)./sum(obj.beta,2);
            expctedValueStickLengths = expctedValueStickLengths(obj.sortingInds);
            expctedValueLogStickLengths = log(expctedValueStickLengths);
            expctedValueLogRemainingStickLengths = log(1-expctedValueStickLengths);
            
            val = expctedValueLogStickLengths + cat(1,0,cumsum(expctedValueLogRemainingStickLengths(1:end-1)));
            
            val = exp(val(obj.unsortingInds));
        end
        function val = get.truncationLevel(obj)
            val = size(obj.beta,1);
        end
        function val = get.expectedValueAlpha(obj)
            
            alphaParams = obj.alphaGammaParams;
            if length(alphaParams) < 2
                val = alphaParams;
            else
                val = alphaParams(1)./alphaParams(2);
            end
        end
        
        function self = defaultParameters(self, truncationLevel)
            % Initialize beta
            self.counts = zeros(truncationLevel,1);
            self.beta = ones(truncationLevel,2); % Each stick has a [1 alpha] prior
            self.beta(:,2) = self.expectedValueAlpha; % If alpha is certain it will be taken care of in the get.expectedValueAlpha method
            
            self.sortingInds = (1:truncationLevel)';
            self.unsortingInds = self.sortingInds;
        end
        function tf = isValid(self)
            tf = ~isempty(self.beta);
        end
    end
end


