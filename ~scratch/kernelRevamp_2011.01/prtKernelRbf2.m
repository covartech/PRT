classdef prtKernelRbf2 < prtKernel2
    
    properties
        sigma = 1;
    end 
    
    properties (Hidden)
        internalDataSet
    end
    
    methods
        function Obj = train(Obj,ds)
            Obj.internalDataSet = ds;
            Obj.isTrained = true;
        end
        
        function Obj = set.sigma(Obj,value)
            if ~prtUtilIsPostiveScalar(value)
                error('prtKernelRbf:set','Value of sigma must be a positive scalar');
            end
            Obj.sigma = value;
        end
        
        function dsOut = run(Obj,ds)
            if ~Obj.isTrained
                error('prtKernelRbf:run','Attempt to run an untrained kernel; use kernel.train(ds) to train');
            end
            if Obj.internalDataSet.nObservations == 0
                dsOut = prtDataSetClass;
            else
                gram = prtKernelRbf2.eval(ds.getObservations,Obj.internalDataSet.getObservations,Obj.sigma);
                dsOut = ds.setObservations(gram);
            end
        end
        
        function nDimensions = getNumDimensions(Obj)
            if ~Obj.isTrained
                error('prtKernelRbf:getNumDimensions','Attempt to calculate nDimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            nDimensions = Obj.internalDataSet.nObservations;
        end
        
        function Obj = retainKernelDimensions(Obj,keepLogical)
            if ~Obj.isTrained
                error('prtKernelRbf:retainKernelDimensions','Attempt to retain dimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            if islogical(keepLogical) && length(keepLogical) ~= Obj.getNumDimensions
                error('prtKernelRbf:retainKernelDimensions','When using logical indexing for retaining kernels, length of logical vector (%d) must be equal to kernel.getNumDimensions (%d)',length(keepLogical),Obj.getNumDimensions);
            end
            Obj.internalDataSet = Obj.internalDataSet.retainObservations(keepLogical);
        end
    end
    
    methods (Static, Hidden = true)
        function gram = eval(x,y,sigma)
            [n1, d] = size(x);
            [n2, nin] = size(y);
            if d ~= nin
                error('size(x,2) must equal size(y,2)');
            end
            
            %dist2 = prtDistanceLNorm(x,y,2);
            dist2 = repmat(sum((x.^2), 2), [1 n2]) + repmat(sum((y.^2),2), [1 n1]).' - 2*x*(y.');
            
            if numel(sigma) == 1
                gram = exp(-dist2/(sigma.^2));
            else
                gram = exp(-bsxfun(@rdivide,dist2,sigma.^2));
            end
        end
    end
end