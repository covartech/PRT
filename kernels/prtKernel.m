classdef prtKernel
    % prtKernel  Base class for prtKernel objects.
    %
    %   prtKernel is the base class for all prtKernel objects. It is an
    %   abstract class and should not be instantiated. All prtKernel
    %   objects implement the following methods:
    %
    %   X = evaluateGram(OBJ,DS1,DS2)Evaluate the kernel object OBJ trained
    %   at all points in DS1 and evaluated at all points in DS2.  This will
    %   ouput a gram matrix of size DS2.nObservations x
    %   getExpectedNumKernels(OBJ,DS1). This is the main interface function
    %   for most kernel operations.
    %
    %   TRAINEDKERNELCELL = toTrainedKernelArray(OBJ,DSTRAIN,DATAPOINTS)
    %   Output a cell array of M trained kernel objects trained using
    %   the data in prtDataSet DSTRAIN at the observations specified in
    %   DATAPOINTS. DATAPOINTS must be a logical array indicating which
    %   elements of DSTRAIN should be used in training. The default
    %   value is all datapoints.  The trained kernel cell can be used
    %   to maintain only a sparse list of kernels in sparse learning
    %   machines such as used by prtClassRVM, prtClassSVM.
    %
    %   yOut = run(OBJ,DSTEST) Run a trained kernel object (one element of
    %   toTrainedKernelArray) on the data in dsTest.
    %
    %   nDims = getExpectedNumKernels(OBJ,DSTRAIN) Output an integer
    %   containing of the expected number of trained kernels that would be
    %   created using toTrainedKernelArray on all the observations in the
    %   data set DSTRAIN.  For binary kernesls such as prtKernelRbf,
    %   prtKernelPolynomial, this is DSTRSAIN.nObservations, for unary
    %   kernels such as prtKernelDc kernels. this is 1. Other kernel
    %   objects might use other specifications.
    %
    %  See also: prtKernelRbf, prtKernelBinary, prtKernelDc, prtKernelDirect,
    %   prtKernelFeatureDependent, prtKernelHyperbolicTangent,
    %   prtKernelPolynomial,  prtKernelRbfNdimensionScale, prtKernelUnary

    
    methods (Abstract)
        
        % Return a cell array of trained Kernels
        %
        % TRAINEDKERNCELL = KERN.toTrainedKernelArray(DS
        
        trainedKernelCell = toTrainedKernelArray(obj,dsTrain,logical);
        nDims = getExpectedNumKernels(obj,dsTrain);
        
 
        % Evaluate Gram matrix
        % 
        % X = KERN.evaulateGram(DS1,DS2) evaluates the Gram matix of the
        % prtKernel object KERN on DS1 and DS2. DS1 and DS2 must be
        % prtDataSet objects.
        x = evaluateGram(obj,ds1,ds2);
 
        
        yOut = run(obj,dsTest);
    end
    
    methods
        %Default behavior is to play nice; no one has to implement these
        function h = classifierPlot(obj)
            h = nan;
        end
        function h = classifierText(obj)
            h = nan;
        end
        function str = toString(obj)
            % TOSTRING  String description of kernel function
            %
            % STR = KERN.toString returns a string description of the
            % kernel function realized by the prtKernel objet KERN.
            str = sprintf('%s',class(obj));
        end
    end
    
    methods (Static)
        
        function gram = runMultiKernel(trainedKernelCell,ds2)
            %runMultiKernel Evaluate a cell array of trained kernel objects.
            %
            % GRAM = runMultiKernel(TRAINEDKERNERLCELL, DS) evaluates the
            % cell array TRAINEDKERNELCELL on the data in DS, which must be
            % a prtDataSet
            nDims = length(trainedKernelCell);
            gram = zeros(ds2.nObservations,nDims);
            for i = 1:length(trainedKernelCell)
                gram(:,i) = trainedKernelCell{i}.run(ds2);
            end
        end
        
        function gram = evaluateMultiKernelGram(kernelCell,ds1,ds2)
            %evaluateMultiKernelGram Evaluate the gram matrix from a cell array of kernel objects.
            %
            % GRAM = evaluateMultiKernelGram(KERNCELL,DS1,DS2) Outputs a
            % gram matrix GRAM of size ds2.nObservations x
            % sum(prtKernel.nDimsMultiKernel(kernelCell,ds1))
            nDims = prtKernel.nDimsMultiKernel(kernelCell,ds1);
            gram = zeros(ds2.nObservations,sum(nDims));
            start = 1;
            for i = 1:length(kernelCell)
                gram(:,start:start+nDims(i)-1) = kernelCell{i}.evaluateGram(ds1,ds2);
                start = nDims(i)+1;
            end
        end
        
        function nDims = nDimsMultiKernel(kernelCell,ds)
            % Return the expected number of dimensions
            %
            % NDIMS = nDimsMultiKernel(KERNCELL, DS) returns the expected
            % number of dimensions each kernel generates when trained on
            % DS.  The length of nDims is be the same as
            % length(kernelCell), and sum(nDims) is the total number of
            % columns that can be expected in a gram matrix based on
            % KERNCELL and DS.
            if ~isa(kernelCell,'cell')
                kernelCell = {kernelCell};
            end
            nDims = zeros(length(kernelCell),1);
            for i = 1:length(kernelCell)
                nDims(i) = kernelCell{i}.getExpectedNumKernels(ds);
            end
        end
        
        function trainedKernelCell = sparseKernelFactory(kernelCell,dataSet,indices)
            % Generate a cell array of kernels
            %
            %  TRAINEDKERNCELL = sparseKernelFactory(KERNCELL,DS,IDX)
            %  Generates a cell array of kernels from the cell array of
            %  kernels KERNCELL, the training data set DS, and the indices
            %  IDX.
            %
            %  For cell arrays of kernels, elements of indices are
            %  indicative of which column in the entire resulting gram
            %  matrix gets selected.  For example, for a data set of 4
            %  elements, and kernelCell = {prtKernelDc, prtKernelRbf},
            %  nDims from nDimsMultiKernel will be [1,4].  if indices is:
            %   [1 0 0 1 0]
            %  this sparseKernelFactory will return a trained DC kernel,
            %  and a trained RBF kernel based on the third data point in
            %  dataSet
            
            if ~islogical(indices)
                %Logicalize it:
                nDims = prtKernel.nDimsMultiKernel(kernelCell,dataSet);
                trueFalse = false(sum(nDims),1);
                trueFalse(indices) = true;
                indices = trueFalse;
            end
            if ~isa(kernelCell,'cell')
                kernelCell = {kernelCell};
            end
            remainingIndices = logical(indices);
            trainedKernelCell = {};
            for i = 1:length(kernelCell)
                nDims = kernelCell{i}.getExpectedNumKernels(dataSet);
                currentIndices = remainingIndices(1:nDims);
                remainingIndices = remainingIndices(nDims + 1:end);
                if any(currentIndices)
                    trainedKernelArray = kernelCell{i}.toTrainedKernelArray(dataSet,currentIndices);
                    for j = 1:length(trainedKernelArray)
                        trainedKernelCell{end+1} = trainedKernelArray(j); %#ok<AGROW>
                    end
                end
            end
        end
    end
end