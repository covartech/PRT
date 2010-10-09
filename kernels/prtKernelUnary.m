classdef prtKernelUnary < prtKernel
    % Base class for kernel functions that always return a single column of
    % a gramm matrix regardless of training data and testing data.  The
    % classic example of this kind of kernel is a "DC" kernel which has a
    % constant output.  Another example might be a kernel that maps feature
    % vectors into 1-dimensional representations.
    %
    % Most kernels should not inherit from prtKernelUnary, instead, kernels
    % that are functions of the training input data observations (e.g.
    % prtKernelRbf) should inherit from prtKernelBinary, and kernels that
    % operate on each feature dimension independently should inherit from
    % prtKernelFeatureDependent.  Other kernels should inherit directly
    % from prtKernel, which is a pain.
    %
    % Kernels that sub-class from prtKernelUnary must implement two
    % functions:
    %
    %         kernel = trainKernel(obj,x);
    %         yOut = evalKernel(obj,x);  
    
    
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
        
        function gramm = evaluateGramm(obj,ds1,ds2)
            %gramm = evaluateGramm(obj,ds1,ds2)
            % Internal, evaluate the gramm matrix from ds1 to ds2
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
            %gramm = prtKernelRbf.rbfEvalKernel(data1,data2,obj.sigma);
            gramm = nan(size(data2,1),1);
            currKernel = obj.trainKernel(data1);
            gramm(:,1) = evalKernel(currKernel,data2);
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