classdef prtBrvDpHmm < prtBrvHmm
    methods
        
        function obj = prtBrvDpHmm(varargin)
            if nargin < 1
                return
            end
            
            obj.components = varargin{1}(:);
            
            obj.initialProbabilities = prtBrvDiscreteStickBreaking(obj.nComponents);
            obj.initialProbabilities.model.useOptimalSorting = false;
            obj.initialProbabilities.model.useGammaPriorOnScale = false;
            
            obj.transitionProbabilities = repmat(prtBrvDiscreteStickBreaking(obj.nComponents),obj.nComponents,1);
            for s = 1:obj.nComponents
                obj.transitionProbabilities(s).model.useOptimalSorting = false;
                obj.transitionProbabilities(s).model.useGammaPriorOnScale = false;
            end
        end
    end
end
        