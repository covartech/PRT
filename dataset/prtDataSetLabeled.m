classdef prtDataSetLabeled < prtDataSetBase
    
    properties (Abstract,Dependent)
        nTargetDimensions
    end
    
    properties (GetAccess = 'protected',SetAccess = 'protected')
        targetNames = {}
        uniqueTargetNames = {}
    end
    methods
        function obj = setUniqueTargetNames(obj,names)
            
        end
        function names = getUniqueTargetNames(obj,indices)
            names = {};
        end
    end
    methods (Abstract)
        
        targets = getTargets(obj,indices1,indices2)
        %         obj = removeTargetDimensions(obj,indices)
        %         obj = replaceTargets(obj,values,indices)
        %         obs = getObservationsByTarget(obj,target)
        %
        %         obs = getObservationsByTarget(obj,target)
                
        %         NOTE:
        %         if this returns an object, we must re-sort the default
        %         ordering of the getObservationNames, I think we need to
        %         have in internal vector of the "true" order and keep
        %         track of that.  If this just returns the data, then we
        %         don't have to worry
        %         obs = sortObservationsByTarget(obj,ascendDescend)
        
    end
end
