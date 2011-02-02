classdef prtClusterGmm < prtCluster %prtClass %prtAction %should extent prtCluster
    % prtClusterGmm   Gaussian mixture model clustering object
    %
    %    CLUSTER = prtClusterGmm returns a GMM clustering object.
    %
    %    CLUSTER = prtClusterGmm(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassFld object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClusterGmm object inherits all properties from the abstract
    %    class prtCluster. In addition is has the following properties:
    %
    %    nClusters          - Number of cluster centers to learn (default =
    %                         3)
    %
    %    A prtClusterGmm clustering algorithm trains a prtRvGmm random
    %    variable on training data, and at run time, the clustering
    %    algorithm outputs the posterior probability of any particular
    %    point being drawn from one of the nClusters Guassian components.
    %
    %    A prtClusterGmm object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT method from
    %    prtCluster.
    %
    %   Example:
    %
    %   ds = prtDataGenIris;
    %   ds = ds.retainFeatures(2:3);
    %   clusterAlgo = prtClusterGmm;
    %   clusterAlgo = clusterAlgo.train(ds);
    %   plot(clusterAlgo);
    %   
    
      properties (SetAccess=private)
        name = 'GMM Clustering' % K-Means Clustering
        nameAbbreviation = 'GMMCluster' % K-MeansCluster
        isSupervised = false;
    end
    
    properties
        nClusters = 3;
    end
    properties (SetAccess = protected)
        clusterCenters = [];
        gmmRv = prtRvGmm;
    end
    properties (SetAccess = private, Hidden = true)
        uY = [];
    end
    
    methods

        function Obj = set.nClusters(Obj,value)
            if ~prtUtilIsPositiveScalarInteger(value)
                error('prt:prtClusterGmm:nClusters','value (%s) must be a positive scalar integer',mat2str(value));
            end
            Obj.nClusters = value;
        end
        
        function Obj = prtClusterGmm(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            Obj.gmmRv = prtRvGmm('nComponents',Obj.nClusters);
            Obj.gmmRv = Obj.gmmRv.mle(DataSet.getObservations);
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            [p,pCluster] = Obj.gmmRv.pdf(DataSet.getObservations);
            pCluster(sum(pCluster,2) == 0,:) = 1./size(pCluster,2);
            pCluster = bsxfun(@rdivide,pCluster,sum(pCluster,2));
            DataSet = DataSet.setObservations(pCluster);
        end
    end
end