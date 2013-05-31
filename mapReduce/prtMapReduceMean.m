classdef prtMapReduceMean < prtMapReduce
    
    methods
        function map = mapFn(self,dataSet) %#ok<INUSL>
            map = struct('sum',sum(dataSet.X),'counts',size(dataSet.X,1));
        end
        
        function reduce = reduceFn(self,maps) %#ok<INUSL>
            mapStructs = cat(1,maps{:});
            mean = sum(cat(1,mapStructs.sum));
            reduce = mean./sum(cat(1,mapStructs.counts));
        end
    end
end