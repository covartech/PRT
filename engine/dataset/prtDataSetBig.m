classdef prtDataSetBig
    
    properties
        dataHandler
        action
    end
    
    properties (Hidden)
        summaryCache
    end
    
    properties (Hidden)
        maxPool = 4;
    end
    
    methods (Hidden)
        function self = clearSummaryCache(self)
            self.summaryCache = [];
        end
        
        function self = cacheBuild(self,force)
            % self = cacheBuild(self,force)
            %   
            if nargin < 2
                force = false;
            end
            if force || isempty(self.summaryCache)
                [~,self] = self.summarize;
            end
        end
    end
    
    methods
        
        function [summary,self] = summarize(self)
            if isempty(self.summaryCache)
                mrSummary = prtMapReduceSummarizeDataSet;
                self.summaryCache = mrSummary.run(self);
            end
            summary = self.summaryCache;
        end
        
        function self = prtDataSetBig(varargin)
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
            ds = self.internalRunAction(ds);
        end
        function n = getNumBlocks(self)
            n = self.dataHandler.getNumBlocks;
        end
        function type = getDataSetType(self)
            type = self.dataHandler.getDataSetType;
        end
        function ds = getRandomBlock(self)
            ind = ceil((self.getNumBlocks)*rand);
            ds = getBlock(self,ind);
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