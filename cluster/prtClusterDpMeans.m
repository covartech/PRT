classdef prtClusterDpMeans < prtCluster 
    % prtClusterDpMeans
    %   lambda - Maximum squared euclidean distance to a mean
    %
    % http://www.cs.berkeley.edu/~jordan/papers/kulis-jordan-icml12.pdf
    %   Algorithm 1
    %
    %   ds = prtDataGenMary                  % Load a prtDataSet
    %   clusterAlgo = prtClusterDpMeans;      % Create a prtClusterKmeans object
    %
    %   % Set the internal decision rule to be MAP. Not required for
    %   % clustering, but necessary to plot the results.
    %   clusterAlgo.internalDecider = prtDecisionMap;
    %   clusterAlgo = clusterAlgo.train(ds); % Train the cluster algorithm
    %   plot(clusterAlgo);                   % Plot the results
    
    properties (SetAccess=private)
        name = 'DP-Means Clustering';
        nameAbbreviation = 'DPMeans';
    end
    
    properties
        lambda = 10;
        clusterCenters = [];
    end
    
    properties 
        nClusters  = []; % The number of clusters
    end
    
    methods
        function self = prtClusterDpMeans(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,ds)
            self.clusterCenters = prtUtilDpMeans(ds.X, self.lambda);
            self.nClusters  = size(self.clusterCenters,1);
        end
        
        function ds = runAction(self,ds)
            
            distance = prtDistanceEuclidean(ds.getObservations,self.clusterCenters);
            
            [dontNeed,clusters] = min(distance,[],2);  %#ok<ASGLU>
            
            binaryMatrix = zeros(size(clusters,1),self.nClusters);
            for i = 1:self.nClusters
                binaryMatrix(i == clusters,i) = 1;
            end
            ds = ds.setObservations(binaryMatrix);
        end
    end
    methods (Hidden = true)
        function self = pruneSmallClusters(self, requiredMinObservations, ds)
            
            if nargin < 3 || isempty(ds)
                ds = self.dataSet;
            end
            clustered = run(self,ds);
            
            if size(clustered.X) > 1
                [~,X] = max(clustered.X,[],2);
            else
                X = clustered.X;
            end
            clusterCounts = histc(X,1:self.nClusters);
            
            prunedClusters = clusterCounts < requiredMinObservations;
            
            self.clusterCenters = self.clusterCenters(~prunedClusters,:);
            self.nClusters  = size(self.clusterCenters,1);
            
        end
    end
end
