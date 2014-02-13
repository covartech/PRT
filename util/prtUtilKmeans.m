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
%       nFeatures.  If initialMeans is a string, it can be 'random' or
%       'plusplus'. random  which uses random samples from the data to
%       initialize the classMeans. plusplus uses the kMeans++ algorithm
%           Arthur, D. and Vassilvitskii, S. (2007). 
%               k-means++: The advantages of careful seeding.
%               Proceedings of the eighteenth annual ACM-SIAM
%               symposium on Discrete algorithms. 1027?1035.
%       If initialMeans is a double matrix, the rows of the
%       matrix represetnt the initial class means, and nClusters is
%       ignored.  Default is 'plusplus'.
%   
%       distanceMetricFn - prtDistance* function specifying the distance
%       metric to use.  distanceMetricFn(x,x) must return 0.  Default value
%       is @(data,centers)prtDistanceEuclidean(data,centers));
%
%       handleEmptyClusters - string specifying how to handle empty
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


p = inputParser;

%p.addParamValue('initialMeans',randn(50,2)/10);
p.addParamValue('initialMeans','random');
p.addParamValue('distanceMetricFn',@(data,centers)prtDistanceEuclidean(data,centers));
p.addParamValue('handleEmptyClusters','remove');
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
        if isa(inputStructure.initialMeans,'char')
            switch lower(inputStructure.initialMeans)
                case 'random'
                    randInds = max(1,ceil(rand(1,nClusters)*nSamples));
                    classMeans = data(randInds,:);
                case 'plusplus'
                    
                    classMeans = nan(nClusters, size(data,2));
                    classMeans(1,:) = data(max(1,ceil(rand*nSamples)),:);
                    initDistanceMat = nan(nSamples,nClusters);
                    for iCluster = 2:nClusters
                        initDistanceMat(:,iCluster-1) = sum(bsxfun(@minus,data,classMeans(iCluster-1,:)).^2,2); % KMeans++ uses a squared euclidean distance.
                        
                        minDistances = min(initDistanceMat,[],2);
                        drawProbabilities = minDistances./sum(minDistances);
                        
                        newClusterMeanIndex = prtRvUtilRandomSample(drawProbabilities, 1);
                        
                        classMeans(iCluster,:) = data(newClusterMeanIndex,:);
                    end
                    
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
        if inputStructure.logicalMeans
            classMeans = classMeans>0.5;
        end
    end
    
    if ~mod(iter,inputStructure.plotVisualization);
        prtUtilKmeansPlotVisualization(data,classMeans,clusterIndex,inputStructure,iter);
    end
    
    distanceMat = inputStructure.distanceMetricFn(data,classMeans);
    [twiddle,clusterIndex] = min(distanceMat,[],2); %#ok<ASGLU>
    
    %Handle empty clusters:
    nMaxFixSteps = 10;
    for iFix = 1:nMaxFixSteps
        if length(unique(clusterIndex)) ~= nClusters
            invalidClusters = setdiff(1:nClusters,clusterIndex);
            validClusters = intersect(1:nClusters,clusterIndex);
            switch lower(inputStructure.handleEmptyClusters)
                case 'remove'
                    classMeans = classMeans(validClusters,:);
                    nClusters = nClusters - length(invalidClusters);
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
    if iFix == nMaxFixSteps
        maxIterReached = true;
        return
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
    [twiddle,clusterIndex] = min(distanceMat,[],2); %#ok<ASGLU>
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
