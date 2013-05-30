classdef prtMapReduce
    
    properties 
        maxPool = 4;
        maxNumBlocks = inf;
        runParallel = true;  %set to false to debug mapFns
        handleEmptyClusters = 'remove';
    end
    
    methods (Abstract)
        maps = mapFn(self,dataSet)
        reduced = reduceFn(self,maps)
    end
    
    methods
        
        function self = preMapReduceProcess(self,dataSetBig) %#ok<INUSD>
            
        end
        
        function [self,maps,reduced] = postMapReduceProcess(self,dataSetbig,maps,reduced) %#ok<INUSL>
            
        end
        
        function [reduced, maps] = run(self,dataSetBig)
            % [reduced, maps] = run(self,dataSetBig)
            % 
            
            nBlocks = min([self.maxNumBlocks,dataSetBig.getNumBlocks]);
            if isfinite(self.maxNumBlocks) && nBlocks < dataSetBig.getNumBlocks
                blockInds = randperm(dataSetBig.getNumBlocks);
            else
                blockInds = 1:nBlocks;
            end
            
            self = preMapReduceProcess(self,dataSetBig);
            maps = cell(nBlocks,1);
            if self.runParallel
                parfor (i = 1:nBlocks,self.maxPool)
                    theIndex = blockInds(i);
                    ds = dataSetBig.getBlock(theIndex);     %#ok<PFBNS>
                    maps{i} = self.mapFn(ds);         %#ok<PFBNS>
                end;
            else
                for i = 1:nBlocks
                    theIndex = blockInds(i);
                    ds = dataSetBig.getBlock(theIndex);     %#ok<PFBNS>
                    maps{i} = self.mapFn(ds);         %#ok<PFBNS>
                end;
            end
            reduced = self.reduceFn(maps);
            [~,maps,reduced] = postMapReduceProcess(self,dataSetBig,maps,reduced);
        end
        
        function [expectedTime,elapsedTime,maps,reduced] = estimateTime(self,dataSetBig,nIters)
            
            nIters = min([nIters,self.maxNumBlocks,dataSetBig.getNumBlocks]);
            nBlocksTotal = min([self.maxNumBlocks,dataSetBig.getNumBlocks]);
            
            maps = cell(nIters,1);
            tic;
            parfor (i = 1:nIters,self.maxPool)
                ds = dataSetBig.getBlock(i);     %#ok<PFBNS>
                maps{i} = self.mapFn(ds);         %#ok<PFBNS>
            end;
            reduced = self.reduceFn(maps);
            elapsedTime = toc;
            expectedTime = elapsedTime/nIters*nBlocksTotal;
        end
    end
end