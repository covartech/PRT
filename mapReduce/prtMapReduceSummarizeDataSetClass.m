classdef prtMapReduceSummarizeDataSetClass < prtMapReduce
    
    methods
        function self = prtMapReduceSummarizeDataSetClass(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
            
        function map = mapFn(self,dataSet)
            map = dataSet.summarize;
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
            nObservations = sum(cat(1,mapStructs.nObservations));
            nBlocks = length(mapStructs);
            
            reduce = struct('upperBounds',upperBounds,'lowerBounds',lowerBounds,'nFeatures',nFeatures,...
                'nTargetDimensions',nTargetDimensions,'uniqueClasses',uniqueClasses,'nClasses',nClasses,...
                'isMary',isMary,'nObservations',nObservations,'nBlocks',nBlocks);
        end
    end
    
end