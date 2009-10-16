function prtFeatSelector = prtFeatSelGenExhaustive(DS,PrtFeatSelOpt)
%prtFeatSelector = prtFeatSelGenExhaustive(DS,PrtFeatSelOpt)

nFeats = DS.nDimensions;

bestPerformance = -inf;
bestChoose = [];

PrtFeatSelOpt.nFeatures = min(DS.nDimensions,PrtFeatSelOpt.nFeatures);
warning off;
maxIterations = nchoosek(DS.nDimensions,PrtFeatSelOpt.nFeatures);
warning on;

iterationCount = 1;
nextChooseFn = prtNextChoose(DS.nDimensions,PrtFeatSelOpt.nFeatures);
firstChoose = nextChooseFn();
currChoose = firstChoose;

finishedFunction = @(current) isequal(current,firstChoose);

    
if PrtFeatSelOpt.showProgressBar
    h = waitbar(0,sprintf('SFS: Processing Feature %d Out Of %d',iterationCount,maxIterations));
end

while iterationCount == 1 || ~finishedFunction(currChoose)

    waitbar(iterationCount/maxIterations,h);
    
    tempDataSet = prtDataSetLabeled(DS.data(:,currChoose),DS.dataLabels);
    currPerformance = PrtFeatSelOpt.EvaluationMetric(tempDataSet);
    
    if any(currPerformance > bestPerformance) || isempty(bestChoose)
        bestChoose = currChoose;
        bestPerformance = currPerformance;
    elseif currPerformance == bestPerformance
        bestChoose = cat(1,bestChoose,currChoose);
        bestPerformance = cat(1,bestPerformance,currPerformance);
    end
    currChoose = nextChooseFn();
    iterationCount = iterationCount + 1;
end

if PrtFeatSelOpt.showProgressBar
    close(h);
end

if size(bestChoose,1) > 1
    warning(sprintf('multiple identical performing feature sets found with performance %f; randomly selecting one feature set for output',bestPerformance(1)));
    index = max(ceil(rand*size(bestChoose,1)),1);
    bestChoose = bestChoose(index,:);
    bestPerformance = bestPerformance(index,:);
end
prtFeatSelector.performance = bestPerformance;
prtFeatSelector.selectedFeatures = bestChoose;
prtFeatSelector.PrtOptions = PrtFeatSelOpt;