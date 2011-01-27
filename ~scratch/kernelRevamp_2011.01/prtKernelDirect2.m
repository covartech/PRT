classdef prtKernelDirect2 < prtKernel2
    
    properties (SetAccess = private)
        name = 'Direct Kernel';
        nameAbbreviation = 'DirectKernel';
        isSupervised = false;
     end
    
    properties (SetAccess = 'protected')
        retainDimensions
    end
    
    methods (Access = protected, Hidden = true)
        
        function obj = trainAction(obj,ds)
            obj.retainDimensions = true(1,ds.nFeatures);
        end
        
        function yOut = runAction(obj,ds)
            yOut = ds.retainFeatures(obj.retainDimensions);
        end
    end
    methods
        function kernelObj = prtKernelDirect2(varargin)
            kernelObj = prtUtilAssignStringValuePairs(kernelObj,varargin{:});
        end
        
        function nDimensions = nDimensions(Obj)
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
            if ~islogical(keepLogical)
                temp = false(1,Obj.nDimensions);
                temp(keepLogical) = true;
                keepLogical = temp;
            end
            
            Obj.retainDimensions = keepLogical;
        end
    end
end