classdef prtKernelRbfNdimensionScale < prtKernelRbf
    % prtKernelRbfNdimensionScale  Auto-scale radial basis function kernel
    %
    %  kernelObj = prtKernelRbfNdimensionScale; Generates a kernel object
    %  implementing a radial basis function, but with sigma parameter
    %  scaled by the number of features in the training data set.  Kernel
    %  objects are widely used in several prt classifiers, such as
    %  prtClassRvm and prtClassSvm.  RBF kernels implement the following
    %  function for 1 x N vectors x1 and x2:
    %
    %   k(x1,x2) = exp(-sum((x1-x2).^2)./(sigma^2*N));
    %
    %  kernelObj = prtKernelRbfNdimensionScale(param,value,...) with
    %  parameter value strings sets the relevant fields of the
    %  prtKernelRbfNdimensionScale object to have the corresponding values.
    %  prtKernelRbfNdimensionScale objects have the following user-settable
    %  properties:
    %
    %   sigma   - Positive scalar value specifying the width of the
    %       Gaussian kernel in the RBF function; this is further scaled by
    %       the square root of the number of dimensions of the data.
    %       (Default value is 1)
    %
    %  Radial basis function kernels are widely used in the machine
    %  learning literature. Auto-scaling these kernels allows for relative
    %  invariance to the number of dimensions of the data under
    %  consideration.  For more information on these kernels, please refer
    %  to:
    %   
    %  http://en.wikipedia.org/wiki/Support_vector_machine#Non-linear_classification
    %
    %  % Example usage:
    %   ds = prtDataGenBimodal;
    %   k1 = prtKernelRbfNdimensionScale;
    %   k2 = prtKernelRbfNdimensionScale('sigma',2);
    %   
    %   g1 = k1.evaluateGram(ds,ds);
    %   g2 = k2.evaluateGram(ds,ds);
    %
    %   subplot(2,2,1); imagesc(g1); 
    %   subplot(2,2,2); imagesc(g2);
    %
    
    methods

        function obj = prtKernelRbfNdimensionScale(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        function yOut = evalKernel(obj,data)
            sigma = sqrt(obj.sigma.^2*size(obj.kernelCenter,2));
            yOut = prtKernelRbf.rbfEvalKernel(obj.kernelCenter,data,sigma);
        end
        
        %Should really use latex, or have toLatex
        function string = toString(obj)
            % TOSTRING  String description of kernel function
            %
            % STR = KERN.toString returns a string description of the
            % kernel function realized by the prtKernel objet KERN.
            sigma = sqrt(obj.sigma.^2*size(obj.kernelCenter,2));
            string = sprintf('  f(x) = exp(-(x - %s)./(%.2f^2))',mat2str(obj.kernelCenter,2),sigma);
        end
        
    end
end
