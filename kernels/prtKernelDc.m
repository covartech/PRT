classdef prtKernelDc < prtKernelUnary
    
    properties (SetAccess = 'protected')
        fnHandle
    end
    
    methods 
        function obj = initializeUnaryKernel(obj)
            obj.fnHandle = @(x) ones(size(x,1),1);
        end
    end
end