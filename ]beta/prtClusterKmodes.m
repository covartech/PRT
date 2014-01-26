classdef prtClusterKmodes < prtCluster %prtClass %prtAction %should extent prtCluster
    %
    %   Example:
    %
    %   ds = prtDataGenMoon;                 % Load a prtDataSet
    %   clusterAlgo = prtClusterKmodes;      % Create a prtClusterKmeans object
    %   clusterAlgo.nClusters = 3;           % Set the number of desired clusters
    %
    %   % Set the internal decision rule to be MAP. Not required for
    %   % clustering, but necessary to plot the results.
    %   clusterAlgo.internalDecider = prtDecisionMap;
    %   clusterAlgo = clusterAlgo.train(ds); % Train the cluster algorithm
    %   plot(clusterAlgo);                   % Plot the results
    %
    %   See also prtCluster, prtClusterKMeans, prtClusterGmm
    
    properties (SetAccess=private)
        name = 'K-Modes Clustering' % K-Means Clustering
        nameAbbreviation = 'K-ModesCluster' % K-MeansCluster
    end
    
    properties
        nClusters = 3;  % The number of clusters to find
        
        kdeRv = prtRvKde;
        
        handleEmptyClusters = 'remove';  % Action to take when an empty cluster occurs
        distanceMetricFn = @prtDistanceEuclidean;  % The distance metric; should be a function like D = prtDistanceEuclidean(dataSet1,dataSet2)
        initialClusterCenters = 'plusplus';
        trainingPlotVisualization = false;
    end
    
    properties (SetAccess = protected)
        clusterCenters = [];   % The cluster centers
    end
    properties (SetAccess = private, Hidden = true)
        uY = [];
    end
    
    methods
        
        function self = set.nClusters(self,value)
            if ~prtUtilIsPositiveScalarInteger(value)
                error('prt:prtClusterKmodes:nClusters','value (%s) must be a positive scalar integer',mat2str(value));
            end
            self.nClusters = value;
        end
        
        function self = set.handleEmptyClusters(self,value)
            if ~isa(value,'char') || ~any(strcmpi(value,{'exit','regularize'}))
                error('prt:prtClusterKmodes:handleEmptyClusters','value (%s) must be one of ''remove'', or ''random''',mat2str(value));
            end
            self.kmeansHandleEmptyClusters = value;
        end
        function self = set.initialClusterCenters(self,value)
            if isa(value,'char')
                if ~any(strcmpi(value,{'random','plusplus'}))
                    error('prt:prtClusterKmodes:initialClusterCenters','If specified as a string initialClusterCenters must be one of ''random'', or ''plusplus''');
                end
            else
                % initialMeans were specified as a matrix. Assume
                % everything will be ok and let prtUtilKMeans catch errors
            end
            self.initialClusterCenters = value;
        end
        
        function self = set.distanceMetricFn(self,value)
            if ~isa(value,'function_handle')
                error('prt:prtClusterKmeans:distanceMetricFn','distanceMetricFn must be a function handle');
            elseif nargin(value) ~= 2
                error('prt:prtClusterKmeans:distanceMetricFn','distanceMetricFn must be a function handle that takes two input arguments');
            end
            self.distanceMetricFn = value;
        end
        function self = prtClusterKmodes(varargin)
            % Allow for string, value pairs
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,ds)
            %self.clusterCenters = prtUtilKmeans(ds.getObservations,slf.nClusters,'distanceMetricFn',Obj.distanceMetricFn,'handleEmptyClusters',Obj.kmeansHandleEmptyClusters,'initialMeans',Obj.initialMeans);
            
            if ischar(self.initialClusterCenters)
                nInitializeKMeansIterations = 1;
                self.clusterCenters = prtUtilKmeans(ds.getObservations,self.nClusters,'distanceMetricFn',self.distanceMetricFn,'handleEmptyClusters',self.handleEmptyClusters,'initialMeans',self.initialClusterCenters,'maxIterations',nInitializeKMeansIterations);
            else
                self.clusterCenters = self.initialClusterCenters;e
            end
            
            data = ds.data;
            
            [nSamples,nDimensions] = size(data);
            clusterIndexOld = nan(nSamples,1);
            
            nMaxIterations = 100;
            for iteration = 1:nMaxIterations
                
                distanceMat = self.distanceMetricFn(data,self.clusterCenters);
                [twiddle,clusterIndex] = min(distanceMat,[],2); %#ok<ASGLU>
    
                self.trainingIterationPlotVisualization(data,self.clusterCenters,clusterIndex,iteration);
                
                %Handle empty clusters:
                nMaxFixSteps = 10;
                for iFix = 1:nMaxFixSteps
                    if length(unique(clusterIndex)) ~= self.nClusters
                        invalidClusters = setdiff(1:self.nClusters,clusterIndex);
                        validClusters = intersect(1:self.nClusters,clusterIndex);
                        switch lower(inputStructure.handleEmptyClusters)
                            case 'remove'
                                classMeans = classMeans(validClusters,:);
                                self.nClusters = self.nClusters - length(invalidClusters);
                                distanceMat = distanceMat(:,validClusters);
                                [twiddle,clusterIndex] = min(distanceMat,[],2); %#ok<ASGLU>
                            case 'random'
                                randInds = max(1,ceil(rand(1,length(invalidClusters))*nSamples));
                                classMeans(invalidClusters,:) = data(randInds,:);
                                distanceMat =  inputStructure.distanceMetricFn(data,classMeans);
                                [twiddle,clusterIndex] = min(distanceMat,[],2); %#ok<ASGLU>
                            otherwise
                                error('invalid');
                        end
                    else
                        break
                    end
                end
                nSamplesForCdf = 1000;
                newClusters = zeros(self.nClusters,nDimensions);
                for clusterInd = 1:self.nClusters
                    
                    cData = data(clusterIndex == clusterInd,:);
                    for iDim = 1:nDimensions
                        % newClusters(clusterInd,iDim) = % mode(cData(:,iDim)); % would work for discrete data only
                        
                        cRv = mle(self.kdeRv,cData(:,iDim));
                        
                        cXSamples = sort(cat(1,linspace(min(cData(:,iDim)), max(cData(:,iDim)),nSamplesForCdf)',cData(:,iDim)),'ascend');
                        cCdf = cRv.cdf(cXSamples);
                        
                        %cModeInd = find(cCdf >= 0.5,1,'first');
                        [~,cModeInd] = max(cCdf);
                        if isempty(cModeInd) 
                            % Something went horribly wrong
                            cMode = mean(cData(:,iDim));
                        else
                            cMode = cXSamples(cModeInd);
                        end
                        
                        newClusters(clusterInd,iDim) = cMode;
                    end
                end
                self.clusterCenters = newClusters;
            
            
                if iFix == nMaxFixSteps
                    %maxIterReached = true;
                    return
                end
                
                %Check convergence:
                if all(clusterIndexOld == clusterIndex)
                    %maxIterReached = false;
                    return;
                else
                    clusterIndexOld = clusterIndex;
                end
            end
            
            % maxIterReached = iteration == nMaxIterations; 
            
        end
    
                
        function ds = runAction(self,ds)
            
            fn = self.distanceMetricFn;
            distance = fn(ds.getObservations,self.clusterCenters);
            
            if size(distance,1) ~= ds.nObservations || size(distance,2) ~= size(self.clusterCenters,1)
                error('prt:prtClusterKmodes:badDistanceMetric','Expected a matrix of size %s from the distance metric, but distance metric function output a matrix of size %s',mat2str([DataSet.nObservations, size(Obj.clusterCenters,1)]),mat2str(size(distance)));
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
    methods (Hidden)
        function trainingIterationPlotVisualization(~, data,classMeans,clusterIndex,iter)
            
            [nSamples,nDimensions] = size(data); %#ok<ASGLU>
            
            if nDimensions > 3
                warning('prt:prtClusterKmods:iterationPlot','plotVisualization is true, but dimensionality of data (%d) is > 3',nDimensions);
                return;
            end
            ds = prtDataSetClass(data,clusterIndex);
            
            plot(ds);
            hold on;
            switch nDimensions
                case 1
                    plot(classMeans,'b.');
                case 2
                    plot(classMeans(:,1),classMeans(:,2),'b.');
                case 3
                    plot3(classMeans(:,1),classMeans(:,2),classMeans(:,3),'b.');
            end
            hold off;
            title(sprintf('Iteration %d',iter));
            drawnow; %pause;
            
        end
    end
end
