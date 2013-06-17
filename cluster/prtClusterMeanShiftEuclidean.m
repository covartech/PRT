classdef prtClusterMeanShiftEuclidean < prtCluster
    % nMaxClusters   Kmeans clustering object
    %
    %    CLUSTER = prtClusterMeanShift returns a MeanShift clustering object.
    %
    %    CLUSTER = prtClusterMeanShift(PROPERTY1, VALUE1, ...) constructs a
    %    prtClusterMeanShift object CLUSTER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClusterMeanShift object inherits all properties from
    %    the abstract class prtCluster. In addition is has the following
    %    properties:
    %
    %    nClusters              - Maximum Number of cluster to learn 
    %
    %    A prtClusterMeanShift object inherits the TRAIN, RUN,
    %    CROSSVALIDATE and KFOLDS methods from prtAction. It also inherits
    %    the PLOT method from prtCluster.
    %
    %    Invoking the RUN method on a prtClusterMeanShift object classifies
    %    the input data by assigning each observation a label according to
    %    the cluster center it is closest to. The cluster centers are found
    %    during training.
    %
    %   Example:
    %
    %   ds = prtDataGenMary                  % Load a prtDataSet
    %   clusterAlgo = prtClusterMeanShift;   % Create a prtClusterMeanShift object
    %   clusterAlgo.nClusters = 10;       % Set the max number of desired clusters
    %
    %   % Set the internal decision rule to be MAP. Not required for
    %   % clustering, but necessary to plot the results.
    %   clusterAlgo.internalDecider = prtDecisionMap;
    %   clusterAlgo = clusterAlgo.train(ds); % Train the cluster algorithm
    %   plot(clusterAlgo);                   % Plot the results
    %   
    %   See also prtCluster, prtClusterGmm

% Copyright (c) 2013 New Folder Consulting
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
        name = 'Mean Shift Clustering'
        nameAbbreviation = 'MeanShift'
    end
    
    properties
        nClusters = 5;

        nMaxIterations = 100;
        meanShiftThreshold = 1e-5;

        meanSeparationThreshold = 1; % Must be exceeded to 

        membershipDistance = 1;
        distanceFunction = @(ds,mu)prtDistanceEuclidean(ds,mu);

    end
    properties (SetAccess = protected)
        clusterCenters = [];   % The cluster centers
    end
    
    methods
        
        function self = set.nClusters(self,value)
            if ~prtUtilIsPositiveScalarInteger(value)
                error('prt:prtClusterMeanShift:nClusters','value (%s) must be a positive scalar integer',mat2str(value));
            end
            self.nClusters = value;
        end
        
        function self = set.distanceFunction(self,value)
            if ~isa(value,'function_handle')
                error('prt:prtClusterMeanShift:distanceFunction','distanceFunction must be a function handle');
            elseif nargin(value) ~= 2
                error('prt:prtClusterMeanShift:distanceFunction','distanceFunction must be a function handle that takes two input arguments');            
            end
            self.distanceMetricFn = value;
        end
        function self = prtClusterMeanShiftEuclidean(varargin)
            % Allow for string, value pairs
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,ds)
            
            X = ds.X;
            beenMappedToAMean = false(ds.nObservations,1);
            
            means = nan(self.nClusters,ds.nFeatures);
            for iCluster = 1:self.nClusters
                
                if all(beenMappedToAMean) % Visited every point
                    break
                end
                
                cPossibleSeedPoints = find(~beenMappedToAMean);
                cSeedPoint = cPossibleSeedPoints(prtRvUtilRandomSample(length(cPossibleSeedPoints)));
                
                % Pick random point as this mean;
                cMean = X(cSeedPoint,:);
                
                for iter = 1:self.nMaxIterations
                    cD = self.distanceFunction(X, cMean);
                    isMemberThisCluster = cD < self.membershipDistance;
                    
                    beenMappedToAMean(isMemberThisCluster) = true;
                    
                    newMean = mean(X(isMemberThisCluster,:),1);
                    
                    if norm(cMean-newMean) < self.meanShiftThreshold
                        break
                    else
                        cMean = newMean;
                    end
                end
                
                % Throw out cluster if too close to existing
                cGoodMeans = means(~any(isnan(means),2),:);
                if ~isempty(cGoodMeans)
                    
                    distanceFromThisMeanToOthers = self.distanceFunction(cMean, cGoodMeans);
                    
                    if min(distanceFromThisMeanToOthers) < self.meanSeparationThreshold
                        cMean = nan(1,size(X,2)); % Set to nan so that we will throw away below.
                    end
                end
                
                means(iCluster,:) = cMean;
            end
            
            % Clean up - Remove clusters we didn't use or threw away.
            self.clusterCenters = means(~any(isnan(means),2),:);
            
            
        end
        
        function ds = runAction(self,ds)
            
            fn = self.distanceFunction;
            distance = fn(ds.getObservations,self.clusterCenters);
            
            if size(distance,1) ~= ds.nObservations || size(distance,2) ~= size(self.clusterCenters,1)
                error('prt:prtClusterKmeans:badDistanceMetric','Expected a matrix of size %s from the distance metric, but distance metric function output a matrix of size %s',mat2str([DataSet.nObservations, size(Obj.clusterCenters,1)]),mat2str(size(distance)));
            end
            
            %The smallest distance is the expected class:
            [dontNeed,clusters] = min(distance,[],2);  %#ok<ASGLU>
            
            binaryMatrix = zeros(size(clusters,1),self.nClusters);
            for i = 1:self.nClusters
                binaryMatrix(i == clusters,i) = 1;
            end
            ds = ds.setObservations(binaryMatrix);
            
        end
    end
end
