classdef prtKernelBinary < prtKernel
    
    methods
        function objectArray = initializeKernelArray(obj,DataSet)
            if isa(DataSet,'double')
                DataSet = prtDataSetClass(DataSet);
            end
            
            for i = 1:DataSet.nObservations
                objectArray{i,1} = initializeBinaryKernel(obj,DataSet.getObservations(i));
            end
        end
    end
    methods (Abstract)
        object = initializeBinaryKernel(obj,x);
    end
end