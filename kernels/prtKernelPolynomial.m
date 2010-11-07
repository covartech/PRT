classdef prtKernelPolynomial < prtKernelBinary
    % prtKernelPolynomial  Polynomial kernel object
    %
    %  kernelObj = prtKernelPolynomial; Generates a kernel object implementing a
    %  polynomial kernel.  Kernel objects are widely used in several
    %  prt classifiers, such as prtClassRvm and prtClassSvm.  Polynomial kernels
    %  implement the following function for 1 x N vectors x1 and x2:
    %
    %   k(x1,x2) = (x*y'+c).^d;
    %
    %  kernelObj = prtKernelPolynomial(param,value,...) with parameter value
    %  strings sets the relevant fields of the prtKernelPolynomial object to have
    %  the corresponding values.  prtKernelPolynomial objects have the
    %  following user-settable properties:
    %
    %   d   - Positive scalar value specifying the order of the polynomial.
    %       (Default value is 2)
    %
    %   c   - Positive scalar indicating the offset of the polynomial.
    %        (Default value is 0)
    %
    %  Polynomial kernels are widely used in the machine
    %  learning literature. For more information on these kernels, please
    %  refer to:
    %   
    %  http://en.wikipedia.org/wiki/Support_vector_machine#Non-linear_classification
    %
    %  % Example usage:
    %   ds = prtDataGenBimodal;
    %   k1 = prtKernelPolynomial;
    %   k2 = prtKernelPolynomial('d',3);
    %   
    %   g1 = k1.evaluateGram(ds,ds);
    %   g2 = k2.evaluateGram(ds,ds);
    %
    %   subplot(2,2,1); imagesc(g1); 
    %   subplot(2,2,2); imagesc(g2);
    %
    %
    
    properties
        d = 2;    % polynomial order
        c = 0;    % offset
    end
    properties (SetAccess = 'protected')
        kernelCenter = [];   % The kernel center; set during training
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
        function gram = polynomialKernelEval(x,y,d,c)
            [n1, dim1] = size(x);
            [n2, dim2] = size(y);
            if dim1 ~= dim2
                error('size(x,2) must equal size(y,2)');
            end
            
            gram = (x*y'+c).^d;
        end
    end
end
