classdef prtDecision < prtAction
    
    properties 
        classList
    end
    methods
        function obj = set.classList(obj,val)
            obj.classList = val(:);
        end
        function c = get.classList(obj)
            if isempty(obj.classList)
                error('Plotting prtDecisions in cluster methods requires that classList be manually set in postTrainProcessing');
            end
            c = obj.classList;
        end
    end
end