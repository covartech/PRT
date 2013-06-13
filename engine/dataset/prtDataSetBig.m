classdef prtDataSetBig %< prtDataSetBase
    
    properties
        dataHandler
        action

        nFeatures
        nObservations
        nTargetDimensions
    end
    
    properties (Hidden)
        summaryCache
    end
    
    properties (Hidden)
        maxPool = 4;
    end
    
    methods (Hidden)
        function self = summaryClear(self)
            % self = summaryClear(self)
            self.summaryCache = [];
        end
        
        function self = summaryRebuild(self)
            % self = summaryRebuild(self)
            self = summaryClear(self);
            self = summaryBuild(self,true);
        end
        
        function self = summaryBuild(self,force)
            % self = summaryBuild(self,force)
            % 
            if nargin < 2
                force = false;
            end
            if force || isempty(self.summaryCache)
                mrSummary = prtMapReduceSummarizeDataSet;
                self.summaryCache = mrSummary.run(self);
            end
        end
    end
    
    methods
        
        function summary = summarize(self)
            summary = self.summaryCache;
            if isempty(summary)
                error('prtDataSetBig:summaryNotBuild','The data set big object does not have a valid summary; use ds = ds.summaryBuild to build and cache one');
            end
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
    methods % Abstract from prtDataSetBase (We actually don't want to use these)
        
        function n = get.nFeatures(self)
            n = getNumFeatures(self);
        end
        function n = getNumFeatures(self)
            error('prt:prtDataSetBig:doNotUse','This method cannot be used with objects of type prtDataSetBig.');
        end
        
        function n = get.nObservations(self)
            n = getNumObservations(self);
        end
        function n = getNumObservations(self)
            error('prt:prtDataSetBig:doNotUse','This method cannot be used with objects of type prtDataSetBig.');
        end
        
        function n = get.nTargetDimensions(self)
            n = getNumTargetDimensions(self);
        end
        function nTargets = getNumTargetDimensions(self)
            error('prt:prtDataSetBig:doNotUse','This method cannot be used with objects of type prtDataSetBig.');
        end
        
        function targets = getTargets(self,indices)
            error('prt:prtDataSetBig:doNotUse','This method cannot be used with objects of type prtDataSetBig.');
        end
        function data = getData(self,indices)
            error('prt:prtDataSetBig:doNotUse','This method cannot be used with objects of type prtDataSetBig.');
        end
        function self = retainObservationData(self,indices)
            error('prt:prtDataSetBig:doNotUse','This method cannot be used with objects of type prtDataSetBig.');
        end
        function self = catObservationData(self,varargin)
            error('prt:prtDataSetBig:doNotUse','This method cannot be used with objects of type prtDataSetBig.');
        end
        
    end
end