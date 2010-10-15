classdef prtKernelPolynomial < prtKernelBinary
    % xxx NEED HELP xxx
    % prtKernelPolynomial  Polynomial
    %
    %
    %  http://en.wikipedia.org/wiki/Support_vector_machine#Non-linear_classification
    %
    
    properties
        d = 2;    % polynomial order
        c = 0;    % offset
    end
    properties (SetAccess = 'protected')
        kernelCenter = [];   % The kernel center
    end
    methods
        function obj = set.d(obj,value)
            assert(isscalar(value) && value > 0,'d parameter must be scalar and > 0, value provided is %s',mat2str(value));
            obj.d = value;
        end
        
        function obj = prtKernelPolynomial(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        function obj = trainKernel(obj,x)
            obj.kernelCenter = x;
        end
        
        function yOut = evalKernel(obj,data)
            yOut = prtKernelPolynomial.polynomialKernelEval(obj.kernelCenter,data,obj.d,obj.c);
        end
        
    end
    
    methods (Static, Hidden = true)
        function gramm = polynomialKernelEval(x,y,d,c)
            [n1, d] = size(x);
            [n2, nin] = size(y);
            if d ~= nin
                error('size(x,2) must equal size(y,2)');
            end
            
            gramm = (x*y'+c).^d;
        end
    end
end
