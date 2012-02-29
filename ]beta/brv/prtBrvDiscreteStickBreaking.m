classdef prtBrvDiscreteStickBreaking < prtBrvDiscrete
    methods
        function obj = prtBrvDiscreteStickBreaking(varargin)
            if nargin < 1
                return
            end
            obj.model = prtBrvDiscreteStickBreakingHierarchy(varargin{1});
            
        end
        
        function y = conjugateVariationalAverageLogLikelihood(obj, x)
            
            error('Not done yet');
            
        end
        
        function val = expectedLogMean(obj)
            val = obj.model.expectedValueLogProbabilities(:)';
        end
        
        function [phiMat, priorObjs] = mixtureInitialize(objs, priorObjs, x)
            
            error('Not done yet');

        end
        
        function obj = weightedConjugateUpdate(obj, priorObj, x, weights)
            obj.model = obj.model.conjugateUpdate(priorObj.model,bsxfun(@times,x,weights));
        end
        
        function kld = conjugateKld(obj, priorObj)
            kld = obj.model.kld(priorObj.model);
        end
        
        function x = posteriorMeanDraw(obj, n, varargin)
            if nargin < 2
                n = 1;
            end

            probs = exp(obj.model.expectedValueLogProbabilities);
            probs = probs./sum(probs);
            x = prtRvUtilRandomSample(probs, n);
        end
        
        function s = posteriorMeanStruct(obj)
            s.probabilities = exp(obj.model.expectedValueLogProbabilities);
        end
        
        function model = modelDraw(obj)
            model.probabilities = draw(obj.model);
        end
        
        function plot(objs, colors)
            
            error('Not done yet');

        end
        
        function [obj, training] = vbOnlineWeightedUpdate(obj, priorObj, x, weights, lambda, D, prevObj)
            if ~isempty(weights)
                x = bsxfun(@times,x,weights);
            end
            
            [obj.model, training] = obj.model.vbOnlineWeightedUpdate(priorObj.model, sum(x,1), [], lambda, D, prevObj.model);
        end
    end
end