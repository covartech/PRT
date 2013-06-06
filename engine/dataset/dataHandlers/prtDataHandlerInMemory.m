classdef prtDataHandlerInMemory < prtDataHandler
    % prtDataHandlerMatFiles Provide an interface 
    % 
    % h = prtDataHandlerInMemory('dataSet',prtDataGenUnimodal(1000));
    % ds = h.getBlock(1); 
    %
    properties
        dataSet
    end
    
    methods
        
        function self = prtDataHandlerInMemory(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function ds = getNextBlock(self)
            ds = self.getBlock(1);
        end
        
        function ds = getBlock(self,i)
            if i == 1
                ds = self.dataSet;
            else
                error('prt:prtDataHandlerInMemory:oneBlock','By definition a prtDataHandlerInMemory has only one block');
            end
        end
        
        function nBlocks = getNumBlocks(self) %#ok<MANU>
            nBlocks = 1;
        end
        
        function outputClass = getDataSetType(self) 
            outputClass = class(self.dataSet);
        end
    end
end