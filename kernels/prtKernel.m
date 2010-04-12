classdef prtKernel
    %
    %DataSet = prtDataUnimodal;
    %kernel{1} = prtKernelDC;
    %kernel{2} = prtKernelRbf;
    %for i = 1:length(kernel); kernelCell{i} = initializeKernelArray(kernel{i},DataSet); end
    %
    %kernels = cat(1,kernelCell{:})
    %gramm = prtKernelGrammMatrix(DataSet,kernels);
    %imagesc(gramm);
    properties (Abstract, SetAccess = 'protected')
        fnHandle
    end
    properties (SetAccess = 'protected')
        isInitialized = false;
    end
    
    methods
        function values = run(obj,y)
            if ~obj.isInitialized
                error('Kernel object is not initialized; use obj = initializeKernelArray(obj,x) to initialize');
            end
            if isa(y,'double')
                values = obj.fnHandle(y);
            elseif isa(y,'prtDataSetBase')
                values = nan(y.nObservations,1);
                for i = 1:y.nObservations
                    values(i) = obj.fnHandle(y.getObservations(i));
                end
            end
        end
        function h = classifierPlot(obj)
            h = nan;
        end
        function h = classifierText(obj)
            h = nan;
        end
    end
    methods (Abstract)
        objectArray = initializeKernelArray(obj,x)
    end
end