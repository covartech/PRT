classdef prtClusterMeanShift < prtCluster
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
    %    sigma - RBF Kernel Parameter
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
    %   The Algorithm used here is the Accelerated Gaussian Blur Mean Shift
    %   presented in: http://dl.acm.org/citation.cfm?id=1143864
    %   Fast Nonparametric Clustering with Gaussian Blurring Mean-Shift
    %       Miguel A. Carreira-Perpin˜an
    %       ICML 2006
    %
    %   Example:
    %
    %   ds = prtDataGenUnimodal;                  % Load a prtDataSet
    %   clusterAlgo = prtClusterMeanShift('sigma',1);   % Create a prtClusterMeanShift object
    %   clusterAlgo = train(clusterAlgo, ds);
    %
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
        nClusters = nan;
        
        sigma = 1;
        
        minimumClusterSeparation = 1e-3;
        
        nMaxIterations = 100;
        nEntropyBinsFactor = @(N)0.9*N;
        meanShiftThreshold = 1e-3;
        entropyThreshold = 1e-8;
        
        clusterCenters = [];   % The cluster centers
    end
    
    methods
        function self = prtClusterMeanShift(varargin)
            % Allow for string, value pairs
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,ds)
            
            B = self.nEntropyBinsFactor(ds.nObservations);
            
            X = ds.X;
            PI = 1./ds.nObservations*ones(ds.nObservations,1);
            
            hT = nan;
            exitFlag = 0;

            distMat = prtDistanceEuclidean(X,X).^2;
            for iter = 1:self.nMaxIterations
                Xin = X;
                
                W = exp(-1/2/self.sigma*distMat);
                Dinv = diag(1./sum(bsxfun(@times,PI,W),1));
                X = (X'*bsxfun(@times,PI,W)*Dinv)';
                
                eT = sqrt(sum((X-Xin).^2,2));
                
                hTMinus1 = hT;
                
                f = hist(eT,linspace(0,max(eT),B));
                f = f./size(X,1);
                logf = log(f);
                logf(~isfinite(logf)) = 0;
                
                hT = -sum(f.*logf);
                
                if mean(eT) < self.meanShiftThreshold
                    exitFlag = 1;
                    break
                end
                if abs(hT-hTMinus1) < self.entropyThreshold
                    exitFlag = 2;
                    break
                end
                
                % CollapsX and PI
                distMat = prtDistanceEuclidean(X,X).^2;
                
                isTooClose = distMat < self.minimumClusterSeparation;
                isTooClose(logical(eye(size(isTooClose)))) = 0;
                
                if any(isTooClose(:))
                    % We have a collision of some kind
                    [S, C] = graphconncomp(sparse(isTooClose)); % Bio Infomatics toolbox
                    keepMe = true(size(X,1),1);
                    
                    for iCluster = 1:S
                        isThisCluster = C == iCluster;
                        if sum(isThisCluster) > 1
                            cClusterInds = find(isThisCluster);
                            
                            cD = distMat(isThisCluster,isThisCluster);
                            
                            [~, keepThisObs] = min(mean(cD,2));
                            
                            PI(cClusterInds(keepThisObs)) = sum(PI(cClusterInds));
                            
                            cRemoveMe = true(length(cClusterInds),1);
                            cRemoveMe(keepThisObs) = false;
                            keepMe(cClusterInds(cRemoveMe)) = false;
                        end
                    end
                    
                    X = X(keepMe,:);
                    PI = PI(keepMe);
                    distMat = distMat(keepMe,keepMe);
                    
                end
                
            end

            self.clusterCenters = X;
            self.nClusters = size(self.clusterCenters,1);
            switch exitFlag
                case 0 
                    % You didn't exit
                case 1
                    % Mean shift exit
                case 2
                    % Entropy exit
            end
            
        end
        
        function ds = runAction(self,ds)
            
            X = ds.X;
            distance = exp(-1/2/self.sigma*prtDistanceEuclidean(X,self.clusterCenters).^2);
            
            %The smallest distance is the expected class:
            [dontNeed,clusters] = max(distance,[],2);  %#ok<ASGLU>
            
            binaryMatrix = zeros(size(clusters,1),self.nClusters);
            for i = 1:self.nClusters
                binaryMatrix(i == clusters,i) = 1;
            end
            ds = ds.setObservations(binaryMatrix);
            
        end
    end
end
