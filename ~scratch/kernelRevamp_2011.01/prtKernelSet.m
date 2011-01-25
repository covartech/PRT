classdef prtKernelSet < prtKernel2
    
    properties 
        internalKernelCell
    end
    
    methods
        function Obj = prtKernelSet(varargin)
            if nargin == 1 && isa(varargin{1},'prtKernel2');
                Obj.internalKernelCell = varargin{1};
            elseif nargin == 2 && isa(varargin{1},'prtKernel2') && isa(varargin{2},'prtKernel2');
               Obj.internalKernelCell = {varargin{1},varargin{2}};
            end
        end
        
        function Obj = train(Obj,ds)
            for i = 1:length(Obj.internalKernelCell)
                Obj.internalKernelCell{i} = Obj.internalKernelCell{i}.train(ds);
            end
        end
        function dsOut = run(Obj,ds)
            
            for i = 1:length(Obj.internalKernelCell)
                if i == 1
                    dsOut = Obj.internalKernelCell{i}.run(ds);
                else
                    dsOut = dsOut.catFeatures(Obj.internalKernelCell{i}.run(ds));
                end
            end
        end
        
        function nDimensions = getNumDimensions(Obj)
            nDimensions = 0;
            for i = 1:length(Obj.internalKernelCell)
                nDimensions = nDimensions + Obj.internalKernelCell{i}.getNumDimensions;
            end
        end
        
        function Obj = retainKernelDimensions(Obj,keepLogical)
            
            start = 1;
            for i = 1:length(Obj.internalKernelCell)
                nDimensions = Obj.internalKernelCell{i}.getNumDimensions;
                Obj.internalKernelCell{i} = Obj.internalKernelCell{i}.retainKernelDimensions(keepLogical(start:start+nDimensions-1));
                start = start+nDimensions;
            end
        end
    end
end