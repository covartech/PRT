classdef prtMapReduceSummarizeDataSet < prtMapReduce
    
    methods
            
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
            isMary = length(nClasses) > 2;
            
            
            reduce = struct('upperBounds',upperBounds,'lowerBounds',lowerBounds,'nFeatures',nFeatures,...
                'nTargetDimensions',nTargetDimensions,'uniqueClasses',uniqueClasses,'nClasses',nClasses,...
                'isMary',isMary);            
        end
    end
    
end