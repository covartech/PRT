classdef prtClusterKmeans < prtCluster %prtClass %prtAction %should extent prtCluster
    % prtClusterKmeans   Kmeans clustering object
    %
    %    CLUSTER = prtClusterKmeans returns a Kmeans clustering object.
    %
    %    CLUSTER = prtClusterKmeans(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassFld object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClusterKmeans object inherits all properties from the abstract
    %    class prtCluster. In addition is has the following properties:
    %
    %    nClusters          - Number of cluster centers to learn (default =
    %                         3)
    %
    %    kmeansHandleEmptyClusters - How to handle degerate clusters found
    %                         during training; allowed values are 'remove'
    %                         and 'random'.  Default = 'remove'.
    %
    %    For information on the K-Means algorithm, please
    %    refer to the following URL:
    %
    %    http://en.wikipedia.org/wiki/K-means_clustering
    %
    %    A prtClassFld object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT method from
    %    prtCluster.
    %
    %   Example:
    %
    %   ds = prtDataGenIris;
    %   ds = ds.retainFeatures(2:3);
    %   clusterAlgo = prtClusterKmeans;
    %   clusterAlgo = clusterAlgo.train(ds);
    %   plot(clusterAlgo);
    %   
    
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