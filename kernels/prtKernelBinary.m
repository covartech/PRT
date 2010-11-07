classdef prtKernelBinary < prtKernel
    % prtKernelBinary  Abstract super class for binary kernel objects
    %
    % prtKernelBinary is a sub-class of prtKernel that implements all
    % required abstract methods of prtKernel. prtKernelBinary provides a
    % super class for kernels that are functions of both the training data
    % and the testing data in kernel-based learning algorithms.  Binary
    % kernels are probably the most widely used kinds of kernels - examples
    % include rbf kernels, etc.  prtKernelBinary requires that sub-classes
    % implement the following methods:
    %
    %   kernel = trainKernel(obj,xTrain)
    %       Output a kernel object trained using the data sample in xTrain.
    %
    %   yOut = evalKernel(obj,xTest)
    %       Output the value of the kernel function at point xTest.  The
    %       kernel object should have already been trained using xTrain.
    %
    %   See prtKernelRbf.m, prtKernelHyperbolicTangent.m, and
    %   prtKernelPolynomial.m for examples of sub-classing prtKernelBinary.
    %
    
    methods
        
        function nDims = getExpectedNumKernels(obj,ds)
            nDims = ds.nObservations;
        end
        
        function gram = evaluateGram(obj,ds1,ds2)
            
            if ~isa(ds1,'prtDataSetBase')
                ds1 = prtDataSetStandard(ds1);
            end
            if ~isa(ds2,'prtDataSetBase')
                ds2 = prtDataSetStandard(ds2);
            end
            
            %Note, this can be very slow for some kernels; we can speed
            %this up by forcing kernels to implement something like
            %"evaluateGram(obj,ds1,ds2)" that they can write to be fast,
            %but for now we haven't done that.  Actually, clever kernels
            %can just overload this function to make it fast.  
            kernelArray = toTrainedKernelArray(obj,ds1,true(ds1.nObservations,1));
            gram = nan(ds2.nObservations,length(kernelArray));
            for i = 1:length(kernelArray);
                gram(:,i) = evalKernel(kernelArray(i),ds2.getObservations);
            end
        end
        
        function trainedKernelArray = toTrainedKernelArray(obj,dsTrain,logical)
            valid = find(logical);
            trainedKernelArray = repmat(obj,length(valid),1);
            for j = 1:length(valid)
                trainedKernelArray(j) = obj.trainKernel(dsTrain.getObservations(valid(j)));
            end
        end
        
        function yOut = run(obj,ds2)
            if isa(ds2,'prtDataSetBase')
                data = ds2.getObservations;
            else
                data = ds2;
            end
            %yOut = prtKernelRbf.rbfEvalKernel(obj.kernelCenter,data,obj.sigma);
            yOut = evalKernel(obj,data);
        end
        
    end
    methods (Abstract)
        yOut = evalKernel(obj,x);
        kernel = trainKernel(obj,x);
    end
end