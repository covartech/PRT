classdef prtClusterSphericalKmeans < prtCluster
    % prtClusterSphericalKmeans Spherical K-Means Clustering with Cosine
    %     Metric
    %
    % sk = prtClusterSphericalKmeans generates a spherical K-means
    %   clustering object based on the algorithm description in [1] below.
    %   Spherical K-means operates under the assumption that the input data
    %   rows have zero-mean and unit standard deviation.  Otherwise the
    %   resulting clusters may not work very well.
    %
    % sk = prtClusterSphericalKmeans(varargin) enables the inclusion of
    %   various parameter/value pairs.  
    %
    %  
    %  A prtClusterSphericalKmeans object has the following properites:
    % 
    %   nClusters - 3 - The number of clusters to learn
    %   nIters - 10 - the number of clustering iterations to use
    %
    %  A prtClusterSphericalKmeans object also inherits all properties
    %   and functions from the prtCluster class
    %
    % [1] Learning Feature Representations with K-means, Adam Coates and
    % Andrew Y. Ng
    %
    % Example usage:
    %    See the entry in ]blogs\torrione_2013.03.15_CoatesNg_Kmeans for
    %    example usage







    
    properties (SetAccess=private)
        name = 'Spherical K-Means'
        nameAbbreviation = 'SKM'
    end
    
    properties
        nClusters = 3;
        nIters = 10;
    end
    
    properties (SetAccess = protected)
        clusterCenters = [];   % The cluster centers
    end
    
    methods
        
        function self = set.nClusters(self,value)
            if ~prtUtilIsPositiveScalarInteger(value)
                error('prt:prtClusterKmeans:nClusters','value (%s) must be a positive scalar integer',mat2str(value));
            end
            self.nClusters = value;
        end
        
        
        function self = prtClusterSphericalKmeans(varargin)
            % Allow for string, value pairs
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            
            X = dataSet.X;
            d1 = dataSet.bootstrap(self.nClusters); %random inits
            clusters = d1.X';
            
            clusters = bsxfun(@rdivide,clusters,sqrt(sum(clusters.^2,1)));
            clusters(isnan(clusters)) = 0;
            
            inner = X*clusters;
            [val,indJ] = max(inner,[],2);
            
            matInd = sub2ind(size(inner),(1:length(indJ))',indJ);
            boolMat = false(size(inner));
            boolMat(matInd) = true;
            inner(~boolMat) = 0;
            
            for i = 1:self.nIters
                clusters = clusters + X'*inner;
                
                clusters = bsxfun(@rdivide,clusters,sqrt(sum(clusters.^2,1)));
                clusters(isnan(clusters)) = 0;
                
                inner = X*clusters;
                [val,indJ] = max(inner,[],2);
                matInd = sub2ind(size(inner),(1:length(indJ))',indJ);
                boolMat = false(size(inner));
                boolMat(matInd) = true;
                inner(~boolMat) = 0;
            end
            self.clusterCenters = clusters;
        end
        
        function dataSet = runAction(self,dataSet)
            
            X = dataSet.X;
            inner = X*self.clusterCenters;  
            dataSet.X = inner;
            %             [val,indJ] = max(inner,[],2);
            %             matInd = sub2ind(size(inner),(1:length(indJ))',indJ);
            %             boolMat = false(size(inner));
            %             boolMat(matInd) = true;
            %
            %             dataSet.X = double(boolMat);


        end
    end
end
