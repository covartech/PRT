classdef prtKernelRbfNdimensionScale < prtKernelRbf
    %[gramm,nBasis] = prtKernelRbfNdimensionScale(x1,x2,sigma)
    %   sigma <- sqrt(sigma.^2*nDim)
    
    methods
        function yOut = run(obj,ds2)
            sigma = sqrt(obj.sigma.^2*size(obj.kernelCenter,2));
            yOut = prtKernelRbf.rbfEvalKernel(obj.kernelCenter,ds2.getObservations,sigma);
        end
        
        function nDims = getExpectedNumKernels(obj,ds)
            nDims = ds.nObservations;
        end
        
        function gramm = evaluateGramm(obj,ds1,ds2)
            sigma = sqrt(obj.sigma.^2*ds1.nFeatures);
            gramm = prtKernelRbf.rbfEvalKernel(ds1.getObservations,ds2.getObservations,sigma);
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
