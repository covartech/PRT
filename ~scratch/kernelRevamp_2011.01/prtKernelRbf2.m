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
        end
        function dsOut = run(Obj,ds)
            gram = prtKernelRbf2.eval(ds.getObservations,Obj.internalDataSet.getObservations,Obj.sigma);
            dsOut = ds.setObservations(gram);
        end
        function nDimensions = getNumDimensions(Obj)
            nDimensions = Obj.internalDataSet.nObservations;
        end
        
        function Obj = retainKernelDimensions(Obj,keepLogical)
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
            
            dist2 = repmat(sum((x.^2), 2), [1 n2]) + repmat(sum((y.^2),2), [1 n1]).' - 2*x*(y.');
            %dist2 = prtDistanceLNorm(x,y,2);
            
            if numel(sigma) == 1
                gram = exp(-dist2/(sigma.^2));
            else
                gram = exp(-bsxfun(@rdivide,dist2,sigma.^2));
            end
        end
    end
end