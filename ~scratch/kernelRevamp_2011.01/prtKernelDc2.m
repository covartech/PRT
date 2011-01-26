classdef prtKernelDc2 < prtKernel2

    properties (Access = 'protected')
        isRetained = true;
    end
    methods 
        function obj = prtKernelDc2(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
            obj.isTrained = true; %we're always trained... 
        end
        
        function obj = train(obj,~)
            %do nothing
            obj.isTrained = true;
        end
        
        function yOut = run(obj,ds2) %#ok<MANU>
            yOutData = ones(ds2.nObservations,1);
            yOut = ds2.setObservations(yOutData);
        end
        
        function nDimensions = getNumDimensions(Obj)
            if ~Obj.isTrained
                error('prtKernelRbf:getNumDimensions','Attempt to calculate nDimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            nDimensions = double(Obj.isRetained);
        end
        
        function Obj = retainKernelDimensions(Obj,keepLogical)
            if ~Obj.isTrained
                error('prtKernelRbf:retainKernelDimensions','Attempt to retain dimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            if islogical(keepLogical) && length(keepLogical) ~= Obj.getNumDimensions
                error('prtKernelRbf:retainKernelDimensions','When using logical indexing for retaining kernels, length of logical vector (%d) must be equal to kernel.getNumDimensions (%d)',length(keepLogical),Obj.getNumDimensions);
            end
            if ~islogical(keepLogical)
                error('prtKernelRbf:retainKernelDimensions','Logical indexing only, please... better error message coming');
            end
            Obj.isRetained = keepLogical;
        end
    end
end