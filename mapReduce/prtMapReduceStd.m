classdef prtMapReduceStd < prtMapReduce
    % prtMapReduceStd < prtMapReduce
    
    properties
        mean = [];
    end
    
    methods
        function self = preMapReduceProcess(self,dataSetBig)
            if isempty(self.mean)
                disp('calculating MEAN... once');
                self.mean = run(prtMapReduceMean,dataSetBig);
            end
        end
        
        function map = mapFn(self,dataSet) %#ok<INUSL>
            map = struct('sumSquared',sum(dataSet.X.^2),'counts',size(dataSet.X,1));
        end
        
        function reduce = reduceFn(self,maps)
            mapStructs = cat(1,maps{:});
            squared = sum(cat(1,mapStructs.sumSquared));
            squared = squared./sum(cat(1,mapStructs.counts));
            reduce = sqrt(squared - self.mean.^2);
        end
    end
    
end