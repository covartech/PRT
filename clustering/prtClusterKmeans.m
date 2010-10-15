classdef prtClusterKmeans < prtCluster %prtClass %prtAction %should extent prtCluster
    % xxx NEED HELP xxx
      properties (SetAccess=private)
        name = 'K-Means Clustering' % K-Means Clustering
        nameAbbreviation = 'K-MeansCluster' % K-MeansCluster
        isSupervised = false;
    end
    
    properties
        nClusters = 3;
        clusterCenters = [];
        kmeansHandleEmptyClusters = 'remove';
        distanceMetricFn = @prtDistanceEuclidean;
    end
    properties (SetAccess = private, Hidden = true)
        uY = [];
    end
    
    methods
        function Obj = prtClusterKmeans(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            Obj.clusterCenters = prtUtilKmeans(DataSet.getObservations,Obj.nClusters,'distanceMetricFn',Obj.distanceMetricFn,'handleEmptyClusters',Obj.kmeansHandleEmptyClusters);
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            fn = Obj.distanceMetricFn;
            distance = fn(DataSet.getObservations,Obj.clusterCenters);
            
            %The smallest distance is the expected class:
            [dontNeed,clusters] = min(distance,[],2);  %#ok<ASGLU>
            
            binaryMatrix = zeros(size(clusters,1),Obj.nClusters);
            for i = 1:Obj.nClusters
                binaryMatrix(i == clusters,i) = 1;
            end
            DataSet = DataSet.setObservations(binaryMatrix);
        end
    end
end