classdef prtDataSetClassBig

    properties
        dataHandler
    end
    
    properties (Hidden)
        maxPool = 4;
    end
    
    methods
        function self = prtDataSetClassBig(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function out = mapReduce(self, mapFn, reduceFn)
            dh = self.dataHandler;
            parfor (i = 1:self.getNumBlocks,self.maxPool)
                ds = dh.getBlock(i);  %#ok<PFBNS>
                mapOut(i) = mapFn(ds); %#ok<PFBNS>
            end;
            out = reduceFn(mapOut);
        end
    end
    
    % these methods act as a front-end for the internal field dataHandler,
    % passing through commands that should go to the dataHandler seamlessly
    methods 
        function ds = getNextBlock(self)
            ds = self.dataHandler.getNextBlock;
        end
        function ds = getBlock(self,index)
            ds = self.dataHandler.getBlock(index);
        end
        function n = getNumBlocks(self)
            n = self.dataHandler.getNumBlocks;
        end
        function type = getDataSetType(self)
            type = self.dataHandler.getDataSetType;
        end
    end
    
end