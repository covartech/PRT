classdef prtMapReduceSummarizeDataSetClass < prtMapReduce

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


    methods
        function self = prtMapReduceSummarizeDataSetClass(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
            
        function map = mapFn(self,dataSet)
            map = dataSet.summarize;
            map.targetCache = dataSet.targetCache;
            map.targetCache.classNames = dataSet.classNames;
        end
        
        function reduce = reduceFn(self,maps) %#ok<INUSL>
            mapStructs = cat(1,maps{:});
            
            upperBounds = max(cat(1,mapStructs.upperBounds));
            lowerBounds = min(cat(1,mapStructs.lowerBounds));
            nFeatures = unique(cat(1,mapStructs.nFeatures));
            nTargetDimensions = unique(cat(1,mapStructs.nTargetDimensions));
            
            uniqueClasses = unique(cat(1,mapStructs.uniqueClasses));
            nClasses = length(uniqueClasses);
            isMary = nClasses > 2;
            isBinary = nClasses == 2;
            
            nObservations = sum(cat(1,mapStructs.nObservations));
            nBlocks = length(mapStructs);
            
            %Note this stuff wil error for data sets with different numbers
            %of classes.  We have to fix this.
            tc = cat(1,mapStructs.targetCache);
            targetCache.nClasses = nClasses;
            targetCache.hasNans = any(cat(1,tc.hasNans));
            targetCache.nNans = sum(cat(1,tc.hasNans));
            
            %handle data sets with different number of classes per MAT file:
            [targetCache.uniqueClasses,uClassInds] = unique(cat(1,tc.uniqueClasses));
            classes = cat(1,tc.classNames);
            classes = classes(uClassInds);
            targetCache.classNames = classes;
            
            histMat = zeros(nClasses,length(tc));
            for blockInd = 1:length(tc);
                [~,ia,ib] = intersect(uniqueClasses,tc(blockInd).uniqueClasses);
                histMat(ia,blockInd) = tc(blockInd).hist(ib);
            end
            targetCache.hist = sum(histMat,2);
            
            reduce = struct('upperBounds',upperBounds,'lowerBounds',lowerBounds,'nFeatures',nFeatures,...
                'nTargetDimensions',nTargetDimensions,'uniqueClasses',uniqueClasses,'nClasses',nClasses,...
                'isMary',isMary,'nObservations',nObservations,'nBlocks',nBlocks,'targetCache',targetCache,...
                'isSummaryValid',true);
        end
    end
    
end
