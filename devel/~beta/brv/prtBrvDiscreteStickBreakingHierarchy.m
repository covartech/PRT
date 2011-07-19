% PRTBRVDISCRETEHIERARCHY - PRT BRV Discrete hierarchical model structure
%   Has parameters that specify a dirichlet density
classdef prtBrvDiscreteStickBreakingHierarchy
    properties
        sortingInds
    end
    properties
        alphaGammaParams = [1 1];
        beta = [];
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
        function obj = prtBrvDiscreteHierarchy(varargin)
            if nargin < 1
                return
            end
            
            truncationLevel = varargin{1};
            
            % Initialize beta priorBeta, alpha, priorAlpha
            obj.beta = ones(1,varargin{1})/varargin{1};
            
            
            asdfasdfasdfasdfasdf
            
        end
        
        function pis = draw(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             
             vs = prtRvUtilDirichletDraw([obj.beta(:,1),obj.beta(:,2)]);
             vs = vs(:,1);
             
             pis = zeros(truncLevel,1);
             for iPi = 1:length(vs)
                 if iPi == 1
                     pis(iPi) = vs(iPi);
                 else
                     pis(iPi) = exp(log(vs(iPi))+sum(log(1-vs(1:(iPi-1)))));
                 end
             end
             
             pis(end) = 1-sum(pis(1:end-1));
             pis(pis<0) = 0; % This happens in the range of eps sometimes.
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
        function obj = conjugateUpdate(obj,priorObj,counts)
            
            sumIToK = flipud(cumsum(flipud(counts)));
            sumIPlus1ToK = sumIToK-counts;
            
            % Update stick parameters
            obj.beta(:,1) = counts + priorObj.beta(:,1) + 1;
            obj.beta(:,2) = sumIPlus1ToK + priorObj.beta(:,2) + obj.expectedValueAlpha;
            
            % Update alpha Gamma density parameters
            obj.alphaGammaParams(1) = priorObj.alphaGammaParams(1) + obj.truncationLevel;
            eLog1MinusVt = obj.expectedValueLogOneMinusStickLengths;
            obj.alphaGammaParams(2) = priorObj.alphaGammaParams(2) - sum(eLog1MinusVt(isfinite(eLog1MinusVt))); % Sometimes there are -infs at the end
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
            val = obj.expectedValueLogStickLengths + cat(1,cumsum(obj.expectedValueLogOneMinusStickLengths(1:end-1)));
            val(end) = -prtUtilSumExp(val(1:end-1)); % Force sum to 1
        end
        function val = get.posteriorMean(obj)
            val = exp(obj.expectedValueLogProbabilities);
        end
        function val = get.truncationLevel(obj)
            val = size(obj.beta,1);
        end
        function val = get.expectedValueAlpha(obj)
            val = obj.alphaGammaParams(2)./obj.alphaGammaParams(1);
        end
    end
end
