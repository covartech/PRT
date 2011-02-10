function [classMeans,clusterIndex,maxIterReached] = prtUtilKmeans(data,nClusters,varargin)
%[classMeans,clusterIndex] = prtUtilKmeans(data,nClusters)
%   Perform k-means clustering on the nObservations x nFeatures matrix data
%   using nClusters.  classMeans is a matrix of size nClusters (or less) x
%   nFeatures representing the classMeans, and clusterIndex is a
%   nObservations x 1 vector indicating the closest mean to each
%   observation in data.
%
%[classMeans,clusterIndex] = prtUtilKmeans(data,nClusters,param1,value1,...)
%   Enables inputs of parameter/value pairs as described below:
%
%   Parameters:
%       initialMeans - string or double matrix of size nClusters x
%       nFeatures.  If initialMeans is a string, it should be 'random'
%       which uses random samples from the data to initialize the
%       classMeans.  If initialMeans is a double matrix, the rows of the
%       matrix represetnt the initial class means, and nClusters is
%       ignored.  Default is 'random'.
%
%       distanceMetricFn - prtDistance* function specifying the distance
%       metric to use.  distanceMetricFn(x,x) must return 0.  Default value
%       is @(data,centers)prtDistanceEuclidean(data,centers));
%
%       handleEmptyCluster - string specifying how to handle empty
%       clusters.  Allowed values are 'remove' and 'random'.  Default value
%       is 'remove'.
%
%       plotVisualization - bool value specifying whether to display a plot
%       of the current class centers and the corresponding data on every
%       iteration.  plotVisualization can also be a counting number, in
%       which case it specifies how often to update the plot.  Default
%       value is 'false'.
%
%   Example usage:
%
%       ds = prtDataGenBimodal(100);
%       data = ds.getObservations;
%       close all;
%       [classMeans,clusterIndex] = prtUtilKmeans(data,4,'plotVisualization',4);
%
%       close all;
%       [classMeans,clusterIndex] = prtUtilKmeans(data,4,'plotVisualization',4,'distanceMetricFn',@prtDistanceCityBlock);
%

p = inputParser;

%p.addParamValue('initialMeans',randn(50,2)/10);
p.addParamValue('initialMeans','random');
p.addParamValue('distanceMetricFn',@(data,centers)prtDistanceEuclidean(data,centers));
p.addParamValue('handleEmptyClusters','remove');
p.addParamValue('maxIterations',1000);
p.addParamValue('plotVisualization',false);

p.parse(varargin{:});
inputStructure = p.Results;

[nSamples,nDimensions] = size(data); %#ok<NASGU>
clusterIndexOld = nan(nSamples,1);
clusterIndex = [];

for iter = 1:inputStructure.maxIterations

    if iter == 1; %initialize
        if isa(inputStructure.initialMeans,'char')
            switch lower(inputStructure.initialMeans)
                case 'random'
                    randInds = max(1,ceil(rand(1,nClusters)*nSamples));
                    classMeans = data(randInds,:);
                otherwise
                    error('invalid');
            end
        elseif isnumeric(inputStructure.initialMeans)
            classMeans = inputStructure.initialMeans;
            nClusters = size(classMeans,1);
        else
            error('invalid');
        end
    else
        for clusterInd = 1:nClusters
            classMeans(clusterInd,:) = mean(data(clusterIndex == clusterInd,:),1);
        end
    end
    
    if ~mod(iter,inputStructure.plotVisualization);
        prtUtilKmeansPlotVisualization(data,classMeans,clusterIndex,inputStructure,iter);
    end
    
    distanceMat = inputStructure.distanceMetricFn(data,classMeans);
    [twiddle,clusterIndex] = min(distanceMat,[],2);
    
    %Handle empty clusters:
    if length(unique(clusterIndex)) ~= nClusters
        invalidClusters = setdiff(1:nClusters,clusterIndex);
        validClusters = intersect(1:nClusters,clusterIndex);
        switch lower(inputStructure.handleEmptyClusters)
            case 'remove'
                classMeans = classMeans(validClusters,:);
                nClusters = nClusters - length(invalidClusters);
                distanceMat = distanceMat(:,validClusters);
                [twiddle,clusterIndex] = min(distanceMat,[],2);
            case 'random'
                randInds = max(1,ceil(rand(1,length(invalidClusters))*nSamples));
                classMeans(invalidClusters,:) = data(randInds,:);
                distanceMat =  inputStructure.distanceMetricFn(data,classMeans);
                [twiddle,clusterIndex] = min(distanceMat,[],2);
            otherwise
                error('invalid');
        end
    end
    
    %Check convergence:
    if all(clusterIndexOld == clusterIndex)
        maxIterReached = false;
        return;
    else
        clusterIndexOld = clusterIndex;
    end
    
end
maxIterReached = true;


function prtUtilKmeansPlotVisualization(data,classMeans,clusterIndex,inputStructure,iter)

[nSamples,nDimensions] = size(data); %#ok<ASGLU>
if iter == 1
    distanceMat =  inputStructure.distanceMetricFn(data,classMeans);
    [twiddle,clusterIndex] = min(distanceMat,[],2);
end
if nDimensions > 3
    warning('prt:prtUtilKmeans','plotVisualization is true, but dimensionality of data (%d) is > 3',nDimensions);
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
