classdef prtPreProcKmeans < prtPreProc & prtActionBig
    
    properties (SetAccess=private)
        name = 'K-Means PreProcessing' % K-Means Clustering
        nameAbbreviation = 'K-MeansPreProcessing' % K-MeansCluster
    end
    
    properties
        nClusters = 3;                             % The number of clusters to find
        kmeansHandleEmptyClusters = 'remove';      % Action to take when an empty cluster occurs
        distanceMetricFn = @prtDistanceEuclidean;  % The distance metric; should be a function like D = prtDistanceEuclidean(dataSet1,dataSet2)
    end
    
    properties (SetAccess = protected)
        clusterCenters = [];   % The cluster centers
    end
    
    methods
        function Obj = prtPreProcKmeans(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainActionBig(self,dataSetBig)
            
            convergenceTol = 1e-2;
            convergenceTol = .5;
            
            mrKmeans = prtMapReduceKMeans;
            mrKmeans.handleEmptyClusters = self.kmeansHandleEmptyClusters;
            mrKmeans.distanceMetricFn = self.distanceMetricFn;
            mrKmeans.runParallel = true;
            mrKmeans.initialMeans = 'random';
            mrKmeans.maxNumBlocks = inf;
            mrKmeans.nClusters = self.nClusters;
            
            maxIters = 1000;
            prevCenters = self.clusterCenters;
            
            visualizeLearning = false;
            disp('kmeans');
            for iter = 1:maxIters
                clusterCents = mrKmeans.run(dataSetBig);
                self.clusterCenters = clusterCents;
                mrKmeans.clusterCenters = clusterCents;
                
                if visualizeLearning
                    if iter == 1
                        delta = nan;
                    end
                    plot(dataSetBig.getBlock(1));
                    hold on; plot(clusterCents(:,1),clusterCents(:,2),'y*');
                    hold off;
                    title(sprintf('Iter %d; Delta %.2f',iter,delta));
                    drawnow;
                end
                
                if ~isempty(prevCenters)
                    delta = norm(prevCenters(:)-self.clusterCenters(:));
                    if delta < convergenceTol
                        break;
                    end
                end
                prevCenters = self.clusterCenters;
            end
            
        end
        
        function self = trainAction(self,dataSet)
            self.clusterCenters = prtUtilKmeans(dataSet.getObservations,self.nClusters,'distanceMetricFn',self.distanceMetricFn,'handleEmptyClusters',self.kmeansHandleEmptyClusters);
        end
        
        function dataSet = runAction(self,dataSet)
            
            fn = self.distanceMetricFn;
            distance = fn(dataSet.getObservations,self.clusterCenters);
            
            if size(distance,1) ~= dataSet.nObservations || size(distance,2) ~= size(self.clusterCenters,1)
                error('prt:prtClusterKmeans:badDistanceMetric','Expected a matrix of size %s from the distance metric, but distance metric function output a matrix of size %s',mat2str([dataSet.nObservations, size(self.clusterCenters,1)]),mat2str(size(distance)));
            end
            dataSet = dataSet.setObservations(distance);
        end
    end
end