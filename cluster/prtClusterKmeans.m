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
    %    nClusters                 - Number of cluster centers to learn
    %
    %    kmeansHandleEmptyClusters - Speficies operation when degerate clusters found
    %                                occur during training.  Allowed values are 'remove'
    %                                and 'random'.  'remove' eliminates the
    %                                empty cluster. 'random' sets the
    %                                cluster mean to a random vector.
    %
    %    For information on the K-Means algorithm, please
    %    refer to the following URL:
    %
    %    http://en.wikipedia.org/wiki/K-means_clustering
    %
    %    A prtClusterKmeans object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT method from
    %    prtCluster.
    %
    %    Invoking the RUN method on a prtClusterKmeans object classifies
    %    the input data by assigning each observation a label according to
    %    the cluster center it is closest to. The cluster centers are found
    %    during training.
    %
    %   Example:
    %
    %   ds = prtDataGenMary                  % Load a prtDataSet
    %   clusterAlgo = prtClusterKmeans;      % Create a prtClusterKmeans object
    %   clusterAlgo.nClusters = 3;           % Set the number of desired clusters
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
        name = 'K-Means Clustering' % K-Means Clustering
        nameAbbreviation = 'K-MeansCluster' % K-MeansCluster
    end
    
    properties
        nClusters = 3;  % The number of clusters to find
        kmeansHandleEmptyClusters = 'remove';  % Action to take when an empty cluster occurs
        distanceMetricFn = @prtDistanceEuclidean;  % The distance metric; should be a function like D = prtDistanceEuclidean(dataSet1,dataSet2)
        initialMeans = 'plusplus';
    end
    properties (SetAccess = protected)
        clusterCenters = [];   % The cluster centers
    end
    properties (SetAccess = private, Hidden = true)
        uY = [];
    end
    
    methods
        
        function Obj = set.nClusters(Obj,value)
            if ~prtUtilIsPositiveScalarInteger(value)
                error('prt:prtClusterKmeans:nClusters','value (%s) must be a positive scalar integer',mat2str(value));
            end
            Obj.nClusters = value;
        end
        
        function Obj = set.kmeansHandleEmptyClusters(Obj,value)
            if ~isa(value,'char') || ~any(strcmpi(value,{'exit','regularize'}))
                error('prt:prtClusterKmeans:kmeansHandleEmptyClusters','value (%s) must be one of ''remove'', or ''random''',mat2str(value));
            end
            Obj.kmeansHandleEmptyClusters = value;
        end
        function Obj = set.initialMeans(Obj,value)
            if isa(value,'char')
                if ~any(strcmpi(value,{'random','plusplus'}))
                    error('prt:prtClusterKmeans:kmeansInitialMeans','If specified as a string initialMeans must be one of ''random'', or ''plusplus''');
                end
            else
                % initialMeans were specified as a matrix. Assume
                % everything will be ok and let prtUtilKMeans catch errors
            end
            Obj.initialMeans = value;
        end
        
        function Obj = set.distanceMetricFn(Obj,value)
            if ~isa(value,'function_handle')
                error('prt:prtClusterKmeans:distanceMetricFn','distanceMetricFn must be a function handle');
            elseif nargin(value) ~= 2
                error('prt:prtClusterKmeans:distanceMetricFn','distanceMetricFn must be a function handle that takes two input arguments');
            end
            Obj.distanceMetricFn = value;
        end
        function Obj = prtClusterKmeans(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            Obj.clusterCenters = prtUtilKmeans(DataSet.getObservations,Obj.nClusters,'distanceMetricFn',Obj.distanceMetricFn,'handleEmptyClusters',Obj.kmeansHandleEmptyClusters,'initialMeans',Obj.initialMeans);
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            fn = Obj.distanceMetricFn;
            distance = fn(DataSet.getObservations,Obj.clusterCenters);
            
            if size(distance,1) ~= DataSet.nObservations || size(distance,2) ~= size(Obj.clusterCenters,1)
                error('prt:prtClusterKmeans:badDistanceMetric','Expected a matrix of size %s from the distance metric, but distance metric function output a matrix of size %s',mat2str([DataSet.nObservations, size(Obj.clusterCenters,1)]),mat2str(size(distance)));
            end
            
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
