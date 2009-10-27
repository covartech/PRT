classdef prtDataSetInMemoryLabeled < prtDataSetInMemory & prtDataSetBaseInMemoryLabeled & prtDataSetBaseLabeled
    
    properties (Dependent)
        nTargetDimensions   % size(targets,2)
    end
    methods
        function nTargetDimensions = get.nTargetDimensions(obj)
            nTargetDimensions = size(obj.targets,2);
        end
    end
end