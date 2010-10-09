classdef prtKernelDc < prtKernelUnary
    
    methods 
        function obj = prtKernelDc(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        function obj = trainKernel(obj,x)
            %do nothing
        end
        function yOut = evalKernel(obj,ds2)
            yOut = ones(size(ds2,1),1);
        end
        
    end
end