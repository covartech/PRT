classdef prtKernelHyperbolicTangent < prtKernelBinary
    % xxx NEED HELP xxx
    % prtKernelHyperbolicTangent  hyperbolic tangent
    %
    %
    %  http://en.wikipedia.org/wiki/Support_vector_machine#Non-linear_classification
    %
    
    properties
        kappa = 1;    % polynomial order
        c = 1;    % offset
    end
    properties (SetAccess = 'protected')
        kernelCenter = [];   % The kernel center
    end
    methods
        function obj = set.kappa(obj,value)
            assert(isscalar(value) && value > 0,'kappa parameter must be scalar and > 0, value provided is %s',mat2str(value));
            obj.kappa = value;
        end
        
        function obj = set.c(obj,value)
            assert(isscalar(value),'c parameter must be scalar, value provided is %s',mat2str(value));
            obj.c = value;
        end
        
        function obj = prtKernelHyperbolicTangent(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        function obj = trainKernel(obj,x)
            obj.kernelCenter = x;
        end
        
        function yOut = evalKernel(obj,data)
            yOut = prtKernelHyperbolicTangent.hyperbolicTangentKernelEval(obj.kernelCenter,data,obj.kappa,obj.c);
        end
    end
    
    methods (Static, Hidden = true)
        function gramm = hyperbolicTangentKernelEval(x,y,kappa,c)
            [n1, d] = size(x);
            [n2, nin] = size(y);
            if d ~= nin
                error('size(x,2) must equal size(y,2)');
            end
            
            gramm = tanh(kappa*x*y'+c);
        end
    end
end
