classdef prtKernelRbf < prtKernelBinary
    
    properties
        c = 1;
    end
    properties (SetAccess = 'protected')
        fnHandle
        kernelCenter = nan;
    end
    methods 
        function obj = initializeBinaryKernel(obj,x)
            obj.kernelCenter = x;
            obj.fnHandle = @(y) prtKernelRbf.rbfEvalKernel(obj.kernelCenter,y,obj.c);
            obj.isInitialized = true;
        end
    end
    
    methods (Static)
        function gramm = rbfEvalKernel(x,y,c)
            [n1, d] = size(x);
            [n2, nin] = size(y);
            if d ~= nin
                error('size(x,2) must equal size(y,2)');
            end
            
            dist2 = repmat(sum((x.^2)', 1), [n2 1])' + ...
                repmat(sum((y.^2)',1), [n1 1]) - ...
                2*x*(y');
            
            %gramm = exp(-dist2/(c.^2));
            gramm = exp(-bsxfun(@rdivide,dist2,2*c.^2));
            
        end
    end
end