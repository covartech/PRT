classdef prtClusterGmm < prtCluster 
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
    %    nClusters          - Number of cluster centers to learn 
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
    %   ds = prtDataGenUnimodal         % Load a data set
    %   clusterAlgo = prtClusterGmm;    % Create a clustering object
    %   clusterAlgo.nClusters = 2;      % Set the number of clusters
    %
    %   % Set the internal decision rule to be MAP. Not required for
    %   % clustering, but necessary to plot the results.
    %   clusterAlgo.internalDecider = prtDecisionMap;
    % 
    %   clusterAlgo = clusterAlgo.train(ds);  % Train
    %   plot(clusterAlgo);                    % Plot the trained object
    %   
    %   See Also: prtCluster, prtClusterKmeans







    properties (SetAccess=private)
        name = 'GMM Clustering' % GMM Clustering
        nameAbbreviation = 'GMMCluster' % GMMCluster
    end
    
    properties
        nClusters = 3; % The number of clusters
    end
    properties (SetAccess = protected)
        clusterCenters = [];  % The cluster centers
        gmmRv = prtRvGmm;     % The Gaussian mixture model found during training
    end
    
    methods

        function Obj = set.nClusters(Obj,value)
            if ~prtUtilIsPositiveScalarInteger(value)
                error('prt:prtClusterGmm:nClusters','value (%s) must be a positive scalar integer',mat2str(value));
            end
            Obj.nClusters = value;
        end

        % Allow for string, value pairs
        % Allow for string, value pairs
        function Obj = prtClusterGmm(varargin)
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            Obj.gmmRv = prtRvGmm('nComponents',Obj.nClusters);
            Obj.gmmRv = Obj.gmmRv.mle(DataSet.getObservations);
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            [p,pCluster] = Obj.gmmRv.pdf(DataSet.getObservations); %#ok<ASGLU>
            pCluster(sum(pCluster,2) == 0,:) = 1./size(pCluster,2);
            pCluster = bsxfun(@rdivide,pCluster,sum(pCluster,2));
            DataSet = DataSet.setObservations(pCluster);
        end
    end
end
