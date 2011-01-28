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
        function Obj = prtKernelRbfNdimensionScale(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        function dsOut = runAction(Obj,ds)
            if ~Obj.isTrained
                error('prtKernelRbf:run','Attempt to run an untrained kernel; use kernel.train(ds) to train');
            end
            
            if Obj.internalDataSet.nObservations == 0
                dsOut = prtDataSetClass;
            else
                scaledSigma = sqrt(Obj.sigma.^2*Obj.internalDataSet.nFeatures);
                gram = prtKernelRbf2.kernelFn(ds.getObservations,Obj.internalDataSet.getObservations,scaledSigma);
                dsOut = ds.setObservations(gram);
            end
        end
    end
end