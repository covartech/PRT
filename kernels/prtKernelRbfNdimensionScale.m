classdef prtKernelRbfNdimensionScale < prtKernelRbf
    %[gramm,nBasis] = prtKernelRbfNdimensionScale(x1,x2,sigma)
    %   sigma <- sqrt(sigma.^2*nDim)
    
    methods
        function obj = initializeBinaryKernel(obj,x)
            
            nDimensions = size(x,2);
            obj.kernelCenter = x;
            obj.fnHandle = @(y) prtKernelRbf.rbfEvalKernel(obj.kernelCenter,y,sqrt(obj.sigma.^2*nDimensions));
            obj.isInitialized = true;
        end
    end
end
