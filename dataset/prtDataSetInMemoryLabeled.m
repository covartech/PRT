classdef prtDataSetInMemoryLabeled  < prtDataSetBaseInMemoryLabeled & prtDataSetInMemory & prtDataSetBaseLabeled
    % This exists because we want to implement the dependent property nTarget
    % dimensions for in memory labeled datasets but this property is abstract
    % in prtDataSetBaseLabeled so it cant be implimented in
    % prtDataSetBaseInMemoryLabeled because they don't talk.
    % we need to have a subclass of both so that we can implement it.
    
    properties (Dependent)
        nTargetDimensions   % size(targets,2)
    end
    methods
        function nTargetDimensions = get.nTargetDimensions(obj)
            nTargetDimensions = size(obj.targets,2);
        end
    end
end