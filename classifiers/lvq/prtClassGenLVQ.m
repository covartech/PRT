function PrtClassKmeansPrototypes = prtClassGenLVQ(PrtDataSet,PrtClassOpt)
%PrtClassFld = prtClassGenLVQ(PrtDataSet,PrtClassOpt)
%   Generate a LVQ prototype classification algorithm.  
%
%   See: Hastie, Tibshirani, Friedman, "The Elements of Statistical
%   Learning", Chappter 13, p. 414.

% Peter Torrione

x = getObservations(PrtDataSet);
y = getLabels(PrtDataSet);

n = PrtDataSet.nObservations;
p = PrtDataSet.nDimensions;

uY = unique(y);
PrtClassKmeansPrototypes.uY = uY; % we need this for later

%For each class, extract the Fuzzy K-Means class centers:
classMeans = cell(1,length(uY));
for i = 1:length(uY)
    classMeans{i} = prtUtilFuzzyKmeans(x(y == uY(i),:),PrtClassOpt.PrtUtilOptFuzzyKmeans);
end

for iter = 1:PrtClassOpt.maxIterations
    learningRate = PrtClassOpt.learningRate(iter);
    currIndex = max(ceil(rand*size(x,1)),1);
    
    currData = x(currIndex,:);
    currLabel = y(currIndex);
    
    for class = 1:length(uY)
        d = PrtClassOpt.PrtUtilOptFuzzyKmeans.distanceMeasure(currData,classMeans{class});
        [distance(:,class),classIndex(class)] = min(d,[],2);
    end
    [v,index] = min(distance);
    
    if uY(index) == currLabel
        prototype = classMeans{index}(classIndex(index),:);
        prototype = prototype + learningRate * (currData - prototype);
        classMeans{index}(classIndex(index),:) = prototype;
    else
        prototype = classMeans{index}(classIndex(index),:);
        prototype = prototype - learningRate * (currData - prototype);
        classMeans{index}(classIndex(index),:) = prototype;
    end
end

PrtClassKmeansPrototypes.PrtDataSet = PrtDataSet;
PrtClassKmeansPrototypes.PrtOptions = PrtClassOpt;
PrtClassKmeansPrototypes.classMeans = classMeans;