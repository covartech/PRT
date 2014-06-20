function [classMeans,clusterIndex,maxIterReached] = prtUtilDpMeans(data,lambda,varargin)
%[classMeans,clusterIndex] = prtUtilDpMeans(data,lambda)
%   Perform dp-mean clustering on the nObservations x nFeatures matrix data
%   using nMaxClusters.  classMeans is a matrix of size nClusters (or less) x
%   nFeatures representing the classMeans, and clusterIndex is a
%   nObservations x 1 vector indicating the closest mean to each
%   observation in data.
%
% [classMeans,clusterIndex,maxIterReached] = prtUtilDpMeans(data,nMaxClusters,lambda,varargin)
%   Enables inputs of parameter/value pairs as described below:
%
%   Parameters:
%       plotVisualization - bool value specifying whether to display a plot
%       of the current class centers and the corresponding data on every
%       iteration.  plotVisualization can also be a counting number, in
%       which case it specifies how often to update the plot.  Default
%       value is 'false'.
%
%   Example usage:
%
% ds = prtDataGenBimodal(100);
% data = ds.X;
% close all
% [classMeans,clusterIndex] = prtUtilDpMeans(data,10,'plotVisualization',4);
%

p = inputParser;

p.addParamValue('maxIterations',1000);
p.addParamValue('plotVisualization',false);
p.addParamValue('logicalMeans',false);

p.parse(varargin{:});
inputStructure = p.Results;

[nSamples,nDimensions] = size(data); %#ok<NASGU>
clusterIndexOld = nan(nSamples,1);
clusterIndex = [];

for iter = 1:inputStructure.maxIterations

    if iter == 1; %initialize
        classMeans = mean(data,1);
        nClusters = 1;
    end
    
    clusterIndex = zeros(size(data,1),1);
    for iObs = 1:size(data,1)
        distances = sum(bsxfun(@minus,classMeans, data(iObs,:)).^2,2);
        
        [minClusterDistance,clusterIndex(iObs)] = min(distances);
        
        if minClusterDistance > lambda
            nClusters = nClusters + 1;
            clusterIndex(iObs) = nClusters;
            classMeans = cat(1, classMeans, data(iObs,:));
        end
    end
    
    if ~mod(iter,inputStructure.plotVisualization);
        prtUtilDpMeansPlotVisualization(data,classMeans,clusterIndex,inputStructure,iter);
    end
    
    for clusterInd = 1:nClusters
        cMean =  mean(data(clusterIndex == clusterInd,:),1);
        
        if isempty(cMean)
            cMean = nan(1,size(data,2));
        end
        classMeans(clusterInd,:) = cMean;
    end
    if inputStructure.logicalMeans
        classMeans = classMeans>0.5;
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

function prtUtilDpMeansPlotVisualization(data,classMeans,clusterIndex,inputStructure,iter)

[nSamples,nDimensions] = size(data); %#ok<ASGLU>
if iter == 1
    distanceMat =  prtDistanceEuclidean(data,classMeans).^2;
    [twiddle,clusterIndex] = min(distanceMat,[],2); %#ok<ASGLU>
end
if nDimensions > 3
    warning('prt:prtUtilDpMeans','plotVisualization is true, but dimensionality of data (%d) is > 3',nDimensions);
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
