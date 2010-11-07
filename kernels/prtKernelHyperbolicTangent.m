classdef prtKernelHyperbolicTangent < prtKernelBinary
    % prtKernelHyperbolicTangent  Hyperbolic tangent kernel
    %
    %  kernelObj = prtKernelHyperbolicTangent; Generates a kernel object
    %  implementing a hyperbolic tangent.  Kernel objects are widely used
    %  in several prt classifiers, such as prtClassRvm and prtClassSvm.
    %  Hyperbolic tangent kernels implement the following function for 1 x
    %  N vectors x1 and x2:
    %
    %   k(x1,x2) = tanh(kappa*x1*x2'+c);
    %
    %  kernelObj = prtKernelHyperbolicTangent(param,value,...) with
    %  parameter value strings sets the relevant fields of the
    %  prtKernelHyperbolicTangent object to have the corresponding values.
    %  prtKernelHyperbolicTangent objects have the following user-settable
    %  properties:
    %
    %   kappa   - Positive scalar value specifying the gain on the inner
    %      product between x1 and x2 (default 1)
    %
    %   c       - Scalar value specifying DC offset in hyperbolic tangent
    %      function
    %
    %  For more information on these kernels, please refer to:
    %   
    %  http://en.wikipedia.org/wiki/Support_vector_machine#Non-linear_classification
    %
    %  % Example usage:
    %   ds = prtDataGenBimodal;
    %   k1 = prtKernelHyperbolicTangent;
    %   k2 = prtKernelHyperbolicTangent('kappa',2);
    %   
    %   g1 = k1.evaluateGram(ds,ds);
    %   g2 = k2.evaluateGram(ds,ds);
    %
    %   subplot(2,2,1); imagesc(g1); 
    %   subplot(2,2,2); imagesc(g2);
    %
    
    properties
        kappa = 1;    % polynomial order
        c = 0;    % offset
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
        function gram = hyperbolicTangentKernelEval(x,y,kappa,c)
            [n1, d] = size(x);
            [n2, nin] = size(y);
            if d ~= nin
                error('size(x,2) must equal size(y,2)');
            end
            
            gram = tanh(kappa*x*y'+c);
        end
    end
end
