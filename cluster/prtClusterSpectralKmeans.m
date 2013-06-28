classdef prtClusterSpectralKmeans < prtCluster %prtClass %prtAction %should extent prtCluster
    
    % prtClusterSpectralKmeans   Spectral Kmeans clustering object
    %
    %    CLUSTER = prtClusterSpectralKmeans returns a Spectral Kmeans clustering object.
    %
    %    CLUSTER = prtClusterSpectralKmeans(PROPERTY1, VALUE1, ...) constructs a
    %    prtClusterSpectralKmeans object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClusterSpectralKmeans object inherits all properties from the abstract
    %    class prtCluster. In addition is has the following properties:
    %
    %    nClusters                 - Number of cluster centers to learn
    %
    %    nEigs                     - Number of EigenVectors (columns in Spectral Space
    %
    %    sigma                     - RBF Kernel Parameter
    %
    %    distanceMetricFn          - Distance Metric to use for K-means Clustering
    %
    %    kmeansHandleEmptyClusters - Speficies operation when degerate clusters found
    %                                occur during training.  Allowed values are 'remove'
    %                                and 'random'.  'remove' eliminates the
    %                                empty cluster. 'random' sets the
    %                                cluster mean to a random vector.
    %
    %
    %    For information on the Spectral Clustering algorithm, please
    %    refer to the following URL:
    %
    %    http://en.wikipedia.org/wiki/Spectral_clustering
    
    %    For information on the K-Means algorithm, please
    %    refer to the following URL:
    %
    %    http://en.wikipedia.org/wiki/K-means_clustering
    %
    %    A prtClusterSpectralKmeans object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT method from
    %    prtCluster.
    %
    %    Invoking the RUN method on a prtClusterSpectralKmeans object classifies
    %    the input data by assigning each observation a label according to
    %    the cluster center it is closest to. The cluster centers are found
    %    during training.
    
    %   Example:
    %
    %   dataSet = prtDataGenMoon;                           % Load a data set
    %   spectralEmbed = prtClusterSpectralKmeans            % Create a prtPreProcSpectralEmbed object
    %   zmuv=prtPreProcZmuv;                                % Create a prtPreProcZmuv object
    %   algo=zmuv+spectralEmbed;                            % Combine prtPreProcSpectralEmbed and prtPreProcZmuv objects
    % 
    %                        
    %   algo = algo.train(dataSet);       % Train the prtPreProcPca object
    %   dataSetNew = algo.run(dataSet);   % Run
    %   dataSetClustered = prtDataSetClass(dataSet.X,dataSetNew.X);
    % 
    %   % Plot
    %   plot(dataSet);              % Plot Original Data
    %   title('Original Data');
    %   figure;
    %   plot(dataSetClustered);     % Plot Spectral Clustered Data
    %   title('Spectral Clustered Data');
    %
    %   See also prtCluster, prtClusterKmeans, prtClusterGmm
    
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
        name = 'Spectral K-Means Clustering' % Spectral K-means Name
        nameAbbreviation = 'SKMC' % SKMC Abbreviation
    end
    
    properties
        nClusters = 2;  % The number of clusters to find
        nEigs=2;        % Number of eigenvectors (should equal nClusters)
        sigma=.2;       % Sigma for rbf
        distanceMetricFn=@prtDistanceEuclidean;   % Distance metric for K-means
        kmeansHandleEmptyClusters='remove';       % How to handle empty cluster sets (default: remove)
        
    end
    
    properties (SetAccess = protected)
        clusterCenters = [];   % The cluster centers
        eigValues=[];          % Eigenvalue output from Spectral Dimensionality reduction
        eigVectors=[];         % EigenVectors output from Spectral Dimensionality reduction
    end
    
    properties (SetAccess = private, Hidden = true)
        uY = [];
    end
    
    methods
        
        function Obj = set.nClusters(Obj,value)
            if ~prtUtilIsPositiveScalarInteger(value)
                error('prt:prtClusterSpectralKmeans:nClusters','value (%s) must be a positive scalar integer',mat2str(value));
            end
            Obj.nClusters = value;
        end
        
        
        
        function Obj = prtClusterSpectralKmeans(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.kmeansHandleEmptyClusters(Obj,value)
            if ~isa(value,'char') || ~any(strcmpi(value,{'exit','regularize'}))
                error('prt:prtClusterKmeans:kmeansHandleEmptyClusters','value (%s) must be one of ''remove'', or ''random''',mat2str(value));
            end
            Obj.kmeansHandleEmptyClusters = value;
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            [Obj.eigValues, Obj.eigVectors] = prtUtilSpectralDimensionalityReduction(DataSet.X, Obj.nEigs,'sigma',Obj.sigma);          %Spectral dimensionality reduction
            embeddedDataSet=prtDataSetClass(Obj.eigVectors,DataSet.Y);                                                         %Generate prtDatSetClass of data in truncated eigenspace
            Obj.clusterCenters = prtUtilKmeans(embeddedDataSet.getObservations,Obj.nClusters,'distanceMetricFn',Obj.distanceMetricFn,'handleEmptyClusters',Obj.kmeansHandleEmptyClusters);   %Kmeans on spectral
            
            
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            DataSet.X=prtUtilSpectralOutOfSampleExtension(Obj.dataSet.X,DataSet.X,Obj.eigVectors,Obj.eigValues,Obj.sigma);
            
            %% Kmeans Test
            
            fn = Obj.distanceMetricFn;
            distance = fn(DataSet.getObservations,Obj.clusterCenters);
            
            if size(distance,1) ~= DataSet.nObservations || size(distance,2) ~= size(Obj.clusterCenters,1)
                error('prt:prtClusterKmeans:badDistanceMetric','Expected a matrix of size %s from the distance metric, but distance metric function output a matrix of size %s',mat2str([DataSet.nObservations, size(Obj.clusterCenters,1)]),mat2str(size(distance)));
            end
            
            %The smallest distance is the expected class:
            [~,clusters] = min(distance,[],2);
            
            binaryMatrix = zeros(size(clusters,1),Obj.nClusters);
            for i = 1:Obj.nClusters
                binaryMatrix(i == clusters,i) = 1;
            end
            DataSet = DataSet.setObservations(clusters);
            
        end
        
    end
end
