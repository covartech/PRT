classdef prtKernelDirect < prtKernelUnary
    
    properties (SetAccess = 'protected')
        fnHandle
        dimension
    end
    
    methods 
        
        function kernelObj = prtKernelDirect(theDimension)
            kernelObj.dimension = theDimension;
        end
        function obj = initializeUnaryKernel(obj)
            obj.fnHandle = @(x) x(:,obj.dimension);
        end
    end
end