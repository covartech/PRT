classdef prtKernelDirect2 < prtKernel2
    
    properties (SetAccess = 'protected')
        retainDimensions
    end
    
    methods 
        
        function kernelObj = prtKernelDirect(varargin)
            kernelObj = prtUtilAssignStringValuePairs(kernelObj,varargin{:});
        end
        
        function obj = train(obj,ds)
            obj.retainDimensions = true(1,ds.nFeatures);
        end
        
        function yOut = run(obj,ds)
            yOut = ds.retainFeatures(obj.retainDimensions);
        end
        
        function nDimensions = getNumDimensions(Obj)
            if ~Obj.isTrained
                error('prtKernelDirect:getNumDimensions','Attempt to calculate nDimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            nDimensions = length(find(Obj.retainDimensions));
        end
        
        function Obj = retainKernelDimensions(Obj,keepLogical)
            if ~Obj.isTrained
                error('prtKernelDirect:retainKernelDimensions','Attempt to retain dimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            if islogical(keepLogical) && length(keepLogical) ~= Obj.getNumDimensions
                error('prtKernelDirect:retainKernelDimensions','When using logical indexing for retaining kernels, length of logical vector (%d) must be equal to kernel.getNumDimensions (%d)',length(keepLogical),Obj.getNumDimensions);
            end
            Obj.retainDimensions = keepLogical;
        end
    end
end