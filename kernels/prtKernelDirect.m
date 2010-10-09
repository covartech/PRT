classdef prtKernelDirect < prtKernelFeatureDependent
    % prtKernelDirect
    
    properties (SetAccess = 'protected')
        fnHandle
        dimension
    end
    
    methods 
        
        function kernelObj = prtKernelDirect(varargin)
            kernelObj = prtUtilAssignStringValuePairs(kernelObj,varargin{:});
        end
        
        function yOut = evalKernel(obj,x)
            yOut = x(:,obj.dimension);
        end
        function obj = trainKernel(obj,theDimension)
            obj.dimension = theDimension;
        end
    end
end