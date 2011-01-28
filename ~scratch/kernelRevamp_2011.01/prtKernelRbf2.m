classdef prtKernelRbf2 < prtKernel2
    
    properties (SetAccess = private)
        name = 'RBF Kernel';
        nameAbbreviation = 'RBF';
        isSupervised = false;
    end
    properties
        sigma = 1;
    end 
    
    properties (Hidden)
        internalDataSet
    end
    
    methods (Access = protected, Hidden = true)
        function Obj = trainAction(Obj,ds)
            Obj.internalDataSet = ds;
            Obj.isTrained = true;
        end
        
        function dsOut = runAction(Obj,ds)
            if ~Obj.isTrained
                error('prtKernelRbf:run','Attempt to run an untrained kernel; use kernel.train(ds) to train');
            end
            if Obj.internalDataSet.nObservations == 0
                dsOut = prtDataSetClass;
            else
                gram = prtKernelRbf2.kernelFn(ds.getObservations,Obj.internalDataSet.getObservations,Obj.sigma);
                dsOut = ds.setObservations(gram);
            end
        end
    end
    
    methods
        function Obj = prtKernelRbf2(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.sigma(Obj,value)
            if ~prtUtilIsPostiveScalar(value)
                error('prtKernelRbf:set','Value of sigma must be a positive scalar');
            end
            Obj.sigma = value;
        end
        
        function nDimensions = nDimensions(Obj)
            if ~Obj.isTrained
                error('prtKernelRbf:nDimensions','Attempt to calculate nDimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            nDimensions = Obj.internalDataSet.nObservations;
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
            
            Obj.internalDataSet = Obj.internalDataSet.retainObservations(keepLogical);
        end
    end
    
    
    methods(Hidden = true)
        function h = plot(obj)
            x = obj.internalDataSet.getObservations;
            switch(size(x,2))
                case 1
                    h = plot(x,0,'ko','MarkerSize',8,'LineWidth',2);
                case 2
                    h = plot(x(:,1),x(:,2),'ko','MarkerSize',8,'LineWidth',2);
                case 3
                    h = plot3(x(:,1),x(:,2),x(:,3),'ko','MarkerSize',8,'LineWidth',2);
                otherwise
                    h = nan;
            end
        end
    end
    
    methods (Static, Hidden = true)
        function gram = kernelFn(x,y,sigma)
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