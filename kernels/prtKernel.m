classdef prtKernel
    % xxx NEED HELP xxx
    % prtKernel is the super class for all prtKernel objects.  The
    % prtKernel class handles the big-picture internal operatings for
    % kernels; prtkernel objects require that sub-classes implement the
    % following:
    %
    % toTrainedKernelArray, getExpectedNumKernels, evaluateGramm, run
    %
    % Most of that functionality can be found in prtKernelBinary,
    % prtKernelUnary and prtKernelByFeature, so users should not have to
    % sub-class prtKernel directly, unless they're doing something a little
    % odd.
    
    methods (Abstract)
        trainedKernelCell = toTrainedKernelArray(dsTrain,logical);
        nDims = getExpectedNumKernels(dsTrain);
        x = evaluateGramm(ds1,ds2);
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
        
        function gramm = runMultiKernel(trainedKernelCell,ds2)
            %Evaluate a cell array of trained kernel objects on the data in
            %ds2, which should be a prtDataSet
            nDims = length(trainedKernelCell);
            gramm = zeros(ds2.nObservations,nDims);
            for i = 1:length(trainedKernelCell)
                gramm(:,i) = trainedKernelCell{i}.run(ds2);
            end
        end
        
        function gramm = evaluateMultiKernelGramm(kernelCell,ds1,ds2)
            %Evaluate the gramm matrix from a cell array of kernel objects.
            % The output gramm matrix should be of size ds2.nObservations x
            % sum(prtKernel.nDimsMultiKernel(kernelCell,ds1))
            nDims = prtKernel.nDimsMultiKernel(kernelCell,ds1);
            gramm = zeros(ds2.nObservations,sum(nDims));
            start = 1;
            for i = 1:length(kernelCell)
                gramm(:,start:start+nDims(i)-1) = kernelCell{i}.evaluateGramm(ds1,ds2);
                start = nDims(i)+1;
            end
        end
        
        function nDims = nDimsMultiKernel(kernelCell,ds)
            % Return a vector of nDims; the expected number of dimensions
            % each kernel generates when trained on ds.  The length of
            % nDims should be the same as length(kernelCell), and
            % sum(nDims) is the total number of columns that can be
            % expected in a gramm matrix based on kernelCell and ds.
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
            %  indicative of which column *in the entire resulting gramm
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