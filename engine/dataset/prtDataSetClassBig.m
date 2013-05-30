classdef prtDataSetClassBig

    properties
        dataHandler
        action
    end
    
    properties (Hidden)
        maxPool = 4;
    end
    
    methods
        function self = prtDataSetClassBig(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function [reduced, maps] = mapReduce(self, mapReduceObj)            
            [reduced, maps] = mapReduceObj.run(self);
        end
    end
    
    % these methods act as a front-end for the internal field dataHandler,
    % passing through commands that should go to the dataHandler seamlessly
    methods 
        function ds = getNextBlock(self)
            ds = self.dataHandler.getNextBlock;
            ds = self.internalRunAction(ds);
        end
        function ds = getBlock(self,index)
            ds = self.dataHandler.getBlock(index);
            ds = ds.internalRunAction;
        end
        function n = getNumBlocks(self)
            n = self.dataHandler.getNumBlocks;
        end
        function type = getDataSetType(self)
            type = self.dataHandler.getDataSetType;
        end
    end
    
    methods (Hidden)
        function ds = internalRunAction(self,ds)
            if isempty(self.action)
                return
            else
                ds = run(self.action,ds);
            end
        end
    end
    
end