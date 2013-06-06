classdef prtMapReduceKMeans < prtMapReduce
    
    properties
        nClusters = 3;
        clusterCenters = [];
        distanceMetricFn = @(x,y)prtDistanceEuclidean(x,y);
        initialMeans = 'random';
    end
    
    methods
        
        function self = preMapReduceProcess(self,dataSetBig)
            
            if ~isempty(self.clusterCenters)
                return;
            end
            switch lower(self.initialMeans)
                case 'random'
                    randInds = ceil(rand(self.nClusters,1)*dataSetBig.getNumBlocks);
                    for i = 1:self.nClusters;
                        ds = dataSetBig.getBlock(randInds(i));
                        randIndex = ceil(rand*ds.nObservations);
                        self.clusterCenters(i,:) = ds.X(randIndex,:);
                    end
                otherwise
                    error('prtMapReduceKMeans only allows random sample initialization of means');
            end
        end
            
        function map = mapFn(self,dataSet)
            proximity = self.distanceMetricFn(self.clusterCenters,dataSet.X);
            [~,inds] = min(proximity,[],1);
            
            clusterStruct = repmat(struct('sum',[],'counts',[]),1,size(proximity,1));
            for clusterInd = 1:size(proximity,1)
                clusterStruct(1,clusterInd) = struct('sum',sum(dataSet.X(inds == clusterInd,:),1),'counts',sum(inds == clusterInd));
            end
            map = clusterStruct;
        end
        
        function reduce = reduceFn(self,maps) %#ok<INUSL>
            mapStructs = cat(1,maps{:});
            
            reduce = nan(size(mapStructs,2),length(mapStructs(1).sum));
            for clusterInd = 1:size(mapStructs,2)
                mean = sum(cat(1,mapStructs(:,clusterInd).sum));
                %To do: check for empty clusters
                reduce(clusterInd,:) = mean./sum(cat(1,mapStructs(:,clusterInd).counts));
            end
            
        end
    end
    
end