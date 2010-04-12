classdef prtKernelUnary < prtKernel
    
    methods
        function objectArray = initializeKernelArray(obj,~)
            objectArray = initializeUnaryKernel(obj);
            objectArray.isInitialized = true;
            objectArray = {objectArray};
        end
    end
    methods (Abstract)
        object = initializeUnaryKernel(obj);
    end
end
    