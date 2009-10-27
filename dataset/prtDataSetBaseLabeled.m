classdef prtDataSetBaseLabeled < prtDataSetBase
    
    properties (Dependent, Abstract)
        nTargetDimensions
    end
    
    methods (Abstract)
        %All labeled data sets must implement at a minumum the folowing:
        targets = getTargets(obj,indices1,indices2)
        obj = setTargets(obj,targets,indices)
        
        tn = getTargetNames(obj,indices) % This referese to the dimension names
    end
end
