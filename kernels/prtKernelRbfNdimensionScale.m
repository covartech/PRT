classdef prtKernelRbfNdimensionScale < prtKernelRbf
    % xxx NEED HELP xxx
    %[gramm,nBasis] = prtKernelRbfNdimensionScale(x1,x2,sigma)
    %   sigma <- sqrt(sigma.^2*nDim)
    
    methods

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
