classdef prtKernelQMetric < prtKernelBinary







    properties
        lambda = -0.4;
    end
    properties (SetAccess = 'protected')
        kernelCenter = [];   % The kernel center
    end
    
    methods
        
        function obj = set.lambda(obj,value)
            assert(isscalar(value) && value >= -1 && value <= 0,'lambda parameter must be scalar and between -1 and 0, value provided is %s',mat2str(value));
            obj.sigma = value;
        end
        
        function obj = prtKernelQMetric(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        function obj = trainKernel(obj,x)
            obj.kernelCenter = x;
        end
        
        function yOut = evalKernel(obj,data)
            yOut = prtKernelQMetric.qmetricEval(obj.kernelCenter,data,obj.lambda);
        end
        
    end
    
    methods (Static, Hidden = true)
        function gram = qmetricEval(x,y,lambda)
            [n1, d] = size(x);
            [n2, nin] = size(y);
            if d ~= nin
                error('size(x,2) must equal size(y,2)');
            end
            
            gram = prtDistanceQMetric(x,y,lambda);
        end
    end
end
