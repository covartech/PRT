classdef prtKernelFeatureDependent < prtKernel
    % prtKernelFeatureDependent  Abstract super class for feature-dependent
    %   kernel objects
    %
    % prtKernelFeatureDependent is a sub-class of prtKernel that implements
    % all required abstract methods of prtKernel. prtKernelFeatureDependent
    % provides a super class for kernels whose output dimensions are
    % functions of the number of features in a data set (compare with
    % prtKernelUnary (constant output dimensions), and prtKernelBinary
    % (output dimensions function of nObservations.  The main
    % feature-dependent kernel is prtKernelDirect, which implements a
    % linear classifier on the feature dimensions.
    %
    % prtKernelBinary requires that sub-classes implement the following
    % methods:
    %
    %   kernel = trainKernel(obj,featureIndex)
    %       Output a kernel object trained to operate on feature dimension
    %       "feature index".
    %
    %   yOut = evalKernel(obj,xTest)
    %       Output the value of the kernel function at point xTest.  The
    %       kernel object should have already been trained using xTrain,
    %       and should only process data in xTest(:,featureIndex)
    %
    % Note that the output of evaluateGram run on a
    % prtKernelFeatureDependent has dimensionality x1.nObservations x
    % x1.nFeatures.
    %
    % See prtKernelDirect.m, for an example of sub-classing
    % prtKernelFeatureDependent.
    %
    
    methods (Abstract)
        yOut = evalKernel(obj,x);
        kernel = trainKernel(obj,featureIndex);
    end
    
    methods
        
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
            kernelArray = toTrainedKernelArray(obj,ds1,true(ds1.nFeatures,1));
            gram = nan(ds2.nObservations,length(kernelArray));
            for i = 1:length(kernelArray);
                gram(:,i) = evalKernel(kernelArray(i),ds2.getObservations);
            end
        end
    end
    
    methods (Hidden = true)
        function nDims = getExpectedNumKernels(obj,ds)
            nDims = ds.nFeatures;
        end
        
        function trainedKernelArray = toTrainedKernelArray(obj,dsTrain,logical)
            valid = find(logical);
            trainedKernelArray = repmat(obj,length(valid),1);
            for j = 1:length(valid)
                featureIndex = valid(j);
                trainedKernelArray(j) = obj.trainKernel(featureIndex);
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
end