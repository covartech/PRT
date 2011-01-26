classdef prtKernelSet < prtKernel2
    
    %properties (Access = 'protected')
    properties
        internalKernelCell
    end
    
    methods
        function Obj = prtKernelSet(varargin)
            
            c = 1;
            Obj.internalKernelCell = {};
            for i = 1:length(varargin)
                if isa(varargin{i},'prtKernelSet')
                    tempCell = varargin{i}.getKernelCell;
                    Obj.internalKernelCell(c:c+length(tempCell)-1) = tempCell;
                    c = c + length(tempCell);
                elseif isa(varargin{i},'prtKernel2')
                    Obj.internalKernelCell{c} = varargin{i};
                    c = c + 1;
                end
                disp(c)
            end
        end
        
        function Obj = train(Obj,ds)
            for i = 1:length(Obj.internalKernelCell)
                Obj.internalKernelCell{i} = Obj.internalKernelCell{i}.train(ds);
            end
            Obj.isTrained = true;
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
        
        function [nDimensions,nDimensionsArray] = getNumDimensions(Obj)
            
            nDimensionsArray = nan(length(Obj.internalKernelCell),1);
            for i = 1:length(Obj.internalKernelCell)
                nDimensionsArray(i) = Obj.internalKernelCell{i}.getNumDimensions;
            end
            nDimensions = sum(nDimensionsArray);
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
    methods (Hidden = true)
        function kernelCell = getKernelCell(Obj)
            kernelCell = Obj.internalKernelCell;
        end
    end
end
