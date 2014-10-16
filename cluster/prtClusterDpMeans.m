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
