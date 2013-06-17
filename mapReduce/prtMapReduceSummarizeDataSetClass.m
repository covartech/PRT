classdef prtMapReduceSummarizeDataSetClass < prtMapReduce
    
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