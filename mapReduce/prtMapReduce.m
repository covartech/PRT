classdef prtMapReduce

% Copyright (c) 2014 CoVar Applied Technologies
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


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
