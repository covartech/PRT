classdef prtKernel
    % prtKernel  Abstract super class for all prtKernel objects
    %
    % prtKernel is the super class for all prtKernel objects.  The
    % prtKernel class requires that sub-classes implement the following
    % methods:
    %
    %   x = evaluateGram(obj,ds1,ds2)
    %       Evaluate the kernel object obj trained at all points in ds1 and
    %       evaluated at all points in ds2.  This should output a gram
    %       matrix of size ds2.nObservations x
    %       getExpectedNumKernels(obj,ds1).  This is the main interface
    %       function for most kernel operations.
    %
    %   trainedKernelCell = toTrainedKernelArray(obj,dsTrain,logical)
    %       Output a cell array of M trained kernel objects trained using
    %       the data in prtDataSet dsTrain and observations specified in
    %       logical (optional, default to all data points).  The trained
    %       kernel cell can be used to maintain only a sparse list of
    %       kernels in sparse learning machines (e.g. RVM, SVM).
    %
    %   yOut = run(obj,dsTest)
    %       Run a trained kernel object (one element of
    %       toTrainedKernelArray) on the data in dsTest.
    %
    %   nDims = getExpectedNumKernels(obj,dsTrain)
    %       Output an integer containing of the expected number of trained
    %       kernels that would be created using toTrainedKernelArray on all
    %       the observations in the data set dsTrain.  For binary kernesls
    %       (e.g. rbf, polynomial), this is dsTrain.nObservations, for
    %       unary kernels (e.g. DC kernels) this is 1, and other kernel
    %       objects might use other specifications.
    %
    %  General purpose implementations for these abstract methods can be
    %  found in prtKernelBinary, prtKernelUnary, and
    %  prtKernelFeatureDependent; to implement a new kernel class, most
    %  users should be able to directly inherit from one of these rather
    %  than directly from prtKernel.
    %
    
    
    methods (Abstract)
        trainedKernelCell = toTrainedKernelArray(obj,dsTrain,logical);
        nDims = getExpectedNumKernels(obj,dsTrain);
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
            str = sprintf('%s',class(obj));
        end
    end
    
    methods (Static)
        
        function gram = runMultiKernel(trainedKernelCell,ds2)
            %Evaluate a cell array of trained kernel objects on the data in
            %ds2, which should be a prtDataSet
            nDims = length(trainedKernelCell);
            gram = zeros(ds2.nObservations,nDims);
            for i = 1:length(trainedKernelCell)
                gram(:,i) = trainedKernelCell{i}.run(ds2);
            end
        end
        
        function gram = evaluateMultiKernelGram(kernelCell,ds1,ds2)
            %Evaluate the gram matrix from a cell array of kernel objects.
            % The output gram matrix should be of size ds2.nObservations x
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
            % Return a vector of nDims; the expected number of dimensions
            % each kernel generates when trained on ds.  The length of
            % nDims should be the same as length(kernelCell), and
            % sum(nDims) is the total number of columns that can be
            % expected in a gram matrix based on kernelCell and ds.
            if ~isa(kernelCell,'cell')
                kernelCell = {kernelCell};
            end
            nDims = zeros(length(kernelCell),1);
            for i = 1:length(kernelCell)
                nDims(i) = kernelCell{i}.getExpectedNumKernels(ds);
            end
        end
        
        function trainedKernelCell = sparseKernelFactory(kernelCell,dataSet,indices)
            %trainedKernelCell = sparseKernelFactory(kernelCell,dataSet,indices)
            %  Generate a cell array of kernels from the cell array of
            %  kernels kernelCell, the training data set, and the indices.
            %
            %  Note: for cell arrays of kernels, elements of indices are
            %  indicative of which column *in the entire resulting gram
            %  matrix* gets selected.  i.e. for a data set of 4 elements,
            %  and kernelCell = {prtKernelDc, prtKernelRbf}, nDims from
            %  nDimsMultiKernel will be [1,4].  if indices is:
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