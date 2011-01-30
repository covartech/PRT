classdef prtKernelSet < prtKernel
    
    properties (SetAccess = private)
        name = 'Kernel Set';
        nameAbbreviation = 'KernelSet';
        isSupervised = false;
    end
    
    properties 
        kernelCell
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,ds)
            for i = 1:length(Obj.kernelCell)
                Obj.kernelCell{i} = Obj.kernelCell{i}.train(ds);
            end
            Obj.isTrained = true;
        end
        
        function dsOut = runAction(Obj,ds)
            
            for i = 1:length(Obj.kernelCell)
                if i == 1
                    dsOut = Obj.kernelCell{i}.run(ds);
                else
                    %Note: use getObservations here to make sure that
                    %there's no confusion when cat'ing features from
                    %prtDataSetClass and prtDataSetRegress'es
                    dsOut = dsOut.catFeatures(getObservations(Obj.kernelCell{i}.run(ds)));
                end
            end
        end
    end
    methods
        function Obj = prtKernelSet(varargin)
            
            c = 1;
            tempKernelCell = {};
            for i = 1:length(varargin)
                if isa(varargin{i},'prtKernelSet')
                    tempCell = varargin{i}.getKernelCell;
                    tempKernelCell(c:c+length(tempCell)-1) = tempCell;
                    c = c + length(tempCell);
                elseif isa(varargin{i},'prtKernel')
                    tempKernelCell{c} = varargin{i};
                    c = c + 1;
                end
            end
            Obj.kernelCell = tempKernelCell;
        end
        
        function Obj = set.kernelCell(Obj,aCell)
           
            %Check is cell:
            if ~isa(aCell,'cell')
                error('prtKernel:kernelCell','prtKernel''s kernelCell must be a cell array');
            end
            %Check right size:
            if ~isvector(aCell)
                error('prtKernel:kernelCell','prtKernel''s kernelCell must be a vector cell array');
            end
            %             if length(aCell) ~= size(Obj.connectivityMatrix,1)-2
            %                 error('prtKernel:kernelCell','Attempt to change a prtKernel''s kernelCell''s size.  kernelCell must be a vector cell array of length(size(Obj.connectivityMatrix,1)-2)');
            %             end
            
            %Check all are prtKernels:
            if ~all(cellfun(@(c)isa(c,'prtKernel'),aCell))
                error('prtKernel:kernelCell','kernelCell must be a vector cell array of prtKernels')
            end
            
            %Set the internal action cell correctly
            Obj.kernelCell = aCell;
        end
        
    end
    
    methods (Hidden = true)
        function [nDimensions,nDimensionsArray] = nDimensions(Obj)
            
            nDimensionsArray = nan(length(Obj.kernelCell),1);
            for i = 1:length(Obj.kernelCell)
                nDimensionsArray(i) = Obj.kernelCell{i}.nDimensions;
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
            for i = 1:length(Obj.kernelCell)
                nDimensions = Obj.kernelCell{i}.nDimensions;
                Obj.kernelCell{i} = Obj.kernelCell{i}.retainKernelDimensions(keepLogical(start:start+nDimensions-1));
                start = start+nDimensions;
            end
        end
        
    end
    
    methods (Hidden = true)
        function h = plot(Obj)
            %Plot each kernel:
            h = zeros(length(Obj.kernelCell),1);
            for i = 1:length(Obj.kernelCell)
                h(i) = Obj.kernelCell{i}.plot;
            end
        end
    end
    
    methods (Hidden = true)
        function kernelCell = getKernelCell(Obj)
            kernelCell = Obj.kernelCell;
        end
    end
end
