classdef prtDataSetInMemoryLabeled < prtDataSetInMemory & prtDataSetBaseInMemoryLabeled
    
    properties (Dependent)
        nTargetDimensions   % size(targets,2)
    end
    
    % inherits: data, targets from prtDataSetInMemoryTemp
    
    methods
        
        function nTargetDimensions = get.nTargetDimensions(obj)
            nTargetDimensions = size(obj.targets,2);
        end
    end
        
end