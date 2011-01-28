classdef prtKernelSet < prtKernel2
    
    properties (SetAccess = private)
        name = 'Kernel Set';
        nameAbbreviation = 'KernelSet';
        isSupervised = false;
    end
    
    %properties (Access = 'protected') ?
    properties
        internalKernelCell
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,ds)
            for i = 1:length(Obj.internalKernelCell)
                Obj.internalKernelCell{i} = Obj.internalKernelCell{i}.train(ds);
            end
            Obj.isTrained = true;
        end
        
        function dsOut = runAction(Obj,ds)
            
            for i = 1:length(Obj.internalKernelCell)
                if i == 1
                    dsOut = Obj.internalKernelCell{i}.run(ds);
                else
                    %Note: use getObservations here to make sure that
                    %there's no confusion when cat'ing features from
                    %prtDataSetClass and prtDataSetRegress'es
                    dsOut = dsOut.catFeatures(getObservations(Obj.internalKernelCell{i}.run(ds)));
                end
            end
        end
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
            end
        end
        
        function [nDimensions,nDimensionsArray] = nDimensions(Obj)
            
            nDimensionsArray = nan(length(Obj.internalKernelCell),1);
            for i = 1:length(Obj.internalKernelCell)
                nDimensionsArray(i) = Obj.internalKernelCell{i}.nDimensions;
            end
            nDimensions = sum(nDimensionsArray);
        end
        
        function Obj = retainKernelDimensions(Obj,keepLogical)
            
            if ~islogical(keepLogical)
                temp = false(1,Obj.nDimensions);
                temp(keepLogical) = true;
                keepLogical = temp;
            end
            
            start = 1;
            for i = 1:length(Obj.internalKernelCell)
                nDimensions = Obj.internalKernelCell{i}.nDimensions;
                Obj.internalKernelCell{i} = Obj.internalKernelCell{i}.retainKernelDimensions(keepLogical(start:start+nDimensions-1));
                start = start+nDimensions;
            end
        end
        
    end
    
    methods
        function h = plot(Obj)
            %Plot each kernel:
            for i = 1:length(Obj.internalKernelCell)
                Obj.internalKernelCell{i}.plot;
            end
        end
    end
    methods (Hidden = true)
        function kernelCell = getKernelCell(Obj)
            kernelCell = Obj.internalKernelCell;
        end
    end
end
