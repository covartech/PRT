function [classMeans, DS]= prtUtilFuzzyKmeans(X,Options)
%[classMeans, DS]= prtUtilFuzzyKmeans(X,Options)
% xxx Need Help xxx







% Unpack Options
nClusters = Options.nClusters;
distanceFn = Options.distanceMeasure;

b = Options.smoothFactor;
maxIterations = Options.maxIterations;
minClassMeanChange = Options.minClassMeanChange;
minProbChange = Options.minProbChange;
warningOnEmptyCluster = Options.warningDisplay;

if b<=1 && b~=0
    error('smoothFactor (b = %.2f) cannot be <= 1 unless b = 0',b)
end

N = size(X,1); % number of samples
M = size(X,2); % number of dimension

% Run the loop
for iter = 1:maxIterations
    if iter == 1
        randInds = max(1,ceil(rand(1,nClusters)*N));
        classMeans = X(randInds,:);
    else
        classMeans = DSToTheB*X./repmat(sumDSToTheB,1,M);
    end

    % Determine distance between classMeans and X.
	D = distanceFn(X,classMeans);

    % Update DS
    if b~=0
        DSnum = (1./max(D,1e-6)).^(1/(b-1));
        DS = DSnum ./ repmat(sum(DSnum,2),1,nClusters);
        thetaMat = DS.^b.*D;
    else
        DS = ~(D-repmat(min(D,[],2),1,nClusters)); %Pete is amazin
        thetaMat = DS.*D;
    end
   
    % Check for termination
    if iter > 1
        if norm(oldThetaMat - thetaMat(:)) < minProbChange
            if norm(oldClassMeans - classMeans(:)) < minClassMeanChange
                break
            end
        end
    end    
    
    % Determine classMeans
    if b ~= 0
        DSToTheB = (DS.^b)';
    else
        DSToTheB = DS';
    end
    sumDSToTheB = sum(DSToTheB,2);
    % Check and see if we have any empty classes. This can only happen if
    %   b = 0.
    classMeans = DSToTheB*X./repmat(sumDSToTheB,1,M);
    
    if any(sumDSToTheB == 0) % We got issues
        % We will find the point which is farthest from its assigned
        % cluster center and steal it for the empty class. Then we will 
        % change the class mean of the previously empty class to that 
        % point.
        if warningOnEmptyCluster
            disp(['PRT FKM Warning: Class or classes were empty and' ...
                ' have been redetermined']);
        end
        
        emptyClasses = find(~sumDSToTheB);
        for iEC = 1:length(emptyClasses)
            [aBunchOfOnes, cY] = max(DSToTheB);
            [maxVal, sampleToSteal] = max(D(sub2ind(size(D),1:size(D,1),cY)));
            classToStealFrom = cY(sampleToSteal);

            DSToTheB(classToStealFrom,sampleToSteal) = false;
            DSToTheB(emptyClasses(iEC),sampleToSteal) = true;
            sumDSToTheB = sum(DSToTheB,2);
            D = distance(X,classMeans,distanceMeasure,distanceParams{:}); % N x nC
        end
    end

    % Save thetaMat and classMeans for next iter
    oldThetaMat = thetaMat(:);
    oldClassMeans = classMeans(:);
end
