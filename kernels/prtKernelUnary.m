classdef prtKernelUnary < prtKernel
    % prtKernelUnary  Abstract super class for unary kernel objects
    %
    % prtKernelUnary is a sub-class of prtKernel that implements all
    % required abstract methods of prtKernel. prtKernelUnary provides a
    % super class for kernels that are functions of only the testing data
    % in kernel-based learning algorithms.  The most widely kind of unary
    % kernel is the DC kernel, which outputs a constant value (typically 1)
    % for all input vectors.
    %
    %   kernel = trainKernel(obj,xTrain)
    %       Output a kernel object trained using the data sample in xTrain.
    %       For Unary kernels, this function often does nothing.
    %
    %   yOut = evalKernel(obj,xTest)
    %       Output the value of the kernel function at point xTest.  The
    %       kernel object should have already been trained using xTrain.
    %
    % Note that all prtKernelUnary sub-classes output a single column of
    % the Gram matrix regardless of the dimensionality of the input
    % vectors.  This is to ensure that the Gram matrix stays positive
    % definite, and also to save memory and computation time.
    %
    % See prtKernelDc.m, for examples of sub-classing prtKernelUnary.
    %
    % Most kernels should not inherit from prtKernelUnary, instead, kernels
    % that are functions of the training input data observations (e.g.
    % prtKernelRbf) should inherit from prtKernelBinary, and kernels that
    % operate on each feature dimension independently should inherit from
    % prtKernelFeatureDependent.  Other kernels should inherit directly
    % from prtKernel.
    %
    %
    
    methods (Abstract)
        yOut = evalKernel(obj,x);
        kernel = trainKernel(obj,x);
    end
    
    methods
        
        function nDims = getExpectedNumKernels(obj,ds)
            %nDims = getExpectedNumKernels(obj,ds)
            % This is 1 for DC and similar kernels
            nDims = 1;
        end
        
        function gram = evaluateGram(obj,ds1,ds2)
            %gram = evaluateGram(obj,ds1,ds2)
            % Internal, evaluate the gram matrix from ds1 to ds2
            if isa(ds1,'prtDataSetBase')
                data1 = ds1.getObservations;
            else
                data1 = ds1;
            end
            if isa(ds2,'prtDataSetBase')
                data2 = ds2.getObservations;
            else
                data2 = ds2;
            end
            %gram = prtKernelRbf.rbfEvalKernel(data1,data2,obj.sigma);
            gram = nan(size(data2,1),1);
            currKernel = obj.trainKernel(data1);
            gram(:,1) = evalKernel(currKernel,data2);
        end
        
        function trainedKernelArray = toTrainedKernelArray(obj,dsTrain,logical)
            %Turn the kernel into a trained kernel; for unary kernels this
            %is always a single kernel
            trainedKernelArray = obj.trainKernel(dsTrain);
        end
        
        function yOut = run(obj,ds2)
            % Run a trained kernel on ds2
            if isa(ds2,'prtDataSetBase')
                data = ds2.getObservations;
            else
                data = ds2;
            end
            yOut = evalKernel(obj,data);
        end
        
    end
end