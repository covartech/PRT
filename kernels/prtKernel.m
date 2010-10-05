classdef prtKernel

    methods (Abstract)
        trainedKernelCell = toTrainedKernelArray(dsTrain,logical);
        nDims = getExpectedNumKernels(dsTrain);
        x = evaluateGramm(ds1,ds2);
        yOut = run(obj,dsTest);
    end
    
    methods
        function h = classifierPlot(obj)
            h = nan;
        end
        function h = classifierText(obj)
            h = nan;
        end
    end
    
    methods (Static)
        function gramm = runMultiKernel(trainedKernelCell,ds2)
            nDims = length(trainedKernelCell);
            gramm = zeros(ds2.nObservations,nDims);
            for i = 1:length(trainedKernelCell)
                gramm(:,i) = trainedKernelCell{i}.run(ds2);
            end
        end
        function gramm = evaluateMultiKernelGramm(kernelCell,ds1,ds2)
            
            nDims = prtKernel.nDimsMultiKernel(kernelCell,ds1);
            gramm = zeros(ds2.nObservations,sum(nDims));
            start = 1;
            for i = 1:length(kernelCell)
                gramm(:,start:start+nDims(i)-1) = kernelCell{i}.evaluateGramm(ds1,ds2);
                start = nDims(i)+1;
            end
        end
        function nDims = nDimsMultiKernel(kernelCell,ds)
            nDims = zeros(length(kernelCell),1);
            for i = 1:length(kernelCell)
                nDims(i) = kernelCell{i}.getExpectedNumKernels(ds);
            end
        end
        
        function trainedKernelCell = sparseKernelFactory(kernelCell,dataSet,indices)
            
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