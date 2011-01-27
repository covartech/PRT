classdef prtKernelDc2 < prtKernel2

     properties (SetAccess = private)
        name = 'DC Kernel';
        nameAbbreviation = 'DCKern';
        isSupervised = false;
     end
    
    properties (Access = 'protected')
        isRetained = true;
    end
    
    methods (Access = protected, Hidden = true)
        
        function obj = trainAction(obj,~)
            %do nothing
            obj.isTrained = true;
        end
        
        function yOut = runAction(obj,ds2) %#ok<MANU>
            if obj.isRetained
                yOutData = ones(ds2.nObservations,1);
                yOut = ds2.setObservations(yOutData);
            else
                yOut = prtDataSetClass;
            end
        end
    end
    
    methods
        function obj = prtKernelDc2(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
            obj.isTrained = true; %we're always trained... 
        end
        
        function nDimensions = nDimensions(Obj)
            if ~Obj.isTrained
                error('prtKernelRbf:nDimensions','Attempt to calculate nDimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            nDimensions = double(Obj.isRetained);
        end
        
        function Obj = retainKernelDimensions(Obj,keepLogical)
            if ~Obj.isTrained
                error('prtKernelRbf:retainKernelDimensions','Attempt to retain dimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            if islogical(keepLogical) && length(keepLogical) ~= Obj.nDimensions
                error('prtKernelRbf:retainKernelDimensions','When using logical indexing for retaining kernels, length of logical vector (%d) must be equal to kernel.nDimensions (%d)',length(keepLogical),Obj.nDimensions);
            end
            
            if ~islogical(keepLogical)
                temp = false(1,Obj.nDimensions);
                temp(keepLogical) = true;
                keepLogical = temp;
            end
            
            Obj.isRetained = keepLogical;
        end
    end
end