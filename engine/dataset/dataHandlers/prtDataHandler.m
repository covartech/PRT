classdef prtDataHandler < hgsetget
    % prtDataHandler < hgsetget
    %
    
    properties (Dependent)
        nBlocks
    end
    
    methods (Abstract)
        ds = getNextBlock(self)
        ds = getBlock(self,i)
        nBlocks = getNumBlocks(self)
        outputClass = getDataSetType(self) 
    end
    
    methods 
        function n = get.nBlocks(self)
            n = self.getNumBlocks;
        end
    end
end