classdef prtDataSetBaseLabeled < prtDataSetBase
    
    properties (Dependent, Abstract)
        nTargetDimensions
    end
    
    methods (Abstract)
        %All labeled data sets must implement at a minumum the folowing:
        targets = getTargets(obj,indices1,indices2)
        obj = setTargets(obj,targets,indices)
        
        tn = getTargetNames(obj,indices)
        tn = getUniqueTargetNames(obj,indices)
        
        %         I'm not sure if ALL labeled sets, or only multi-dim ones need to
        %         implement these:
        obj = removeTargetDimensions(obj,indices)
        obj = catTargetDimensions(obj,newTargets)
        
        obs = getObservationsByTarget(obj,target)
        obs = getObservationsByUniqueTargetInd(obj,targetInd)
        obs = sortObservationsByTarget(obj,ascendDescend)
        
    end
end
