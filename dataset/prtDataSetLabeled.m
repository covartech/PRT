classdef prtDataSetLabeled < prtDataSetBase
    
    properties (Dependent, Abstract)
        nTargetDimensions
    end
    
    methods (Abstract)
        %All labeled data sets must implement at a minumum the folowing:
        targets = getTargets(obj,indices1,indices2)
        obj = setTargets(obj,targets,indices)
        
        %         obj = replaceTargets(obj,values,indices)
        %         obs = getObservationsByTarget(obj,target)
        %
        %         NOTE:
        %         if this returns an object, we must re-sort the default
        %         ordering of the getObservationNames, I think we need to
        %         have in internal vector of the "true" order and keep
        %         track of that.  If this just returns the data, then we
        %         don't have to worry
        %         obs = sortObservationsByTarget(obj,ascendDescend)
        %         obj = catTargetObservations(obj,indices)
        
        
        %I'm not sure if ALL labeled sets, or only multi-dim ones need to
        %implement these:
        %         obj = removeTargetDimensions(obj,indices)
        %         obj = catTargetDimensions(obj,indices)
                
        
    end
end
