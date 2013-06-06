classdef prtMapReduceSummarizeDataSet < prtMapReduce
    
    methods
        function self = prtMapReduceSummarizeDataSet(varargin)
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
            
            reduce = struct('upperBounds',upperBounds,'lowerBounds',lowerBounds,'nFeatures',nFeatures,...
                'nTargetDimensions',nTargetDimensions);            
        end
    end
    
end