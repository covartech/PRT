classdef prtMapReduce
    
    properties 
        maxPool = 4;
        maxNumBlocks = inf;
    end
    
    methods (Abstract)
        maps = mapFn(self,dataSet)
        reduced = reduceFn(self,maps)
    end
    
    methods
        
        function [reduced, maps] = run(self,dataSetBig)
            % [reduced, maps] = run(self,dataSetBig)
            % 
            
            nBlocks = min([self.maxNumBlocks,dataSetBig.getNumBlocks]);
            if isfinite(self.maxNumBlocks) && nBlocks < dataSetBig.getNumBlocks
                blockInds = randperm(dataSetBig.getNumBlocks);
            else
                blockInds = 1:nBlocks;
            end
            
            maps = cell(nBlocks,1);
            dataHandler = dataSetBig.dataHandler;
            parfor (i = 1:nBlocks,self.maxPool)
                theIndex = blockInds(i);
                ds = dataHandler.getBlock(theIndex);     %#ok<PFBNS>
                maps{i} = self.mapFn(ds);         %#ok<PFBNS>
            end;
            reduced = self.reduceFn(maps);
        end
        
        function [expectedTime,elapsedTime,maps,reduced] = estimateTime(self,dataSetBig,nIters)
            
            nIters = min([nIters,self.maxNumBlocks,dataSetBig.getNumBlocks]);
            nBlocksTotal = min([self.maxNumBlocks,dataSetBig.getNumBlocks]);
            
            maps = cell(nIters,1);
            dataHandler = dataSetBig.dataHandler;
            tic;
            parfor (i = 1:nIters,self.maxPool)
                ds = dataHandler.getBlock(i);     %#ok<PFBNS>
                maps{i} = self.mapFn(ds);         %#ok<PFBNS>
            end;
            reduced = self.reduceFn(maps);
            elapsedTime = toc;
            expectedTime = elapsedTime/nIters*nBlocksTotal;
        end
    end
end