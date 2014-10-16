classdef prtMapReduceKMeans < prtMapReduce

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
