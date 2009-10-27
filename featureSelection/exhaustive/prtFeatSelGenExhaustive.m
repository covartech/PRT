function prtFeatSelector = prtFeatSelGenExhaustive(DS,PrtFeatSelOpt)
%prtFeatSelector = prtFeatSelGenExhaustive(DS,PrtFeatSelOpt)

bestPerformance = -inf;
bestChoose = [];

PrtFeatSelOpt.nFeatures = min(DS.nFeatures,PrtFeatSelOpt.nFeatures);
%warning off;
maxIterations = nchoosek(DS.nFeatures,PrtFeatSelOpt.nFeatures);
%warning on;

iterationCount = 1;
nextChooseFn = prtNextChoose(DS.nFeatures,PrtFeatSelOpt.nFeatures);
firstChoose = nextChooseFn();
currChoose = firstChoose;

finishedFunction = @(current) isequal(current,firstChoose);

    
if PrtFeatSelOpt.showProgressBar
    h = prtUtilWaitbarWithCancel('Exhaustive Feature Selection');
end

notFinished = true;
canceled = false;
while notFinished;

    prtUtilWaitbarWithCancel(iterationCount/maxIterations,h);
    
    tempDataSet = DS.retainFeatures(currChoose);
    currPerformance = PrtFeatSelOpt.EvaluationMetric(tempDataSet);
    
    if any(currPerformance > bestPerformance) || isempty(bestChoose)
        bestChoose = currChoose;
        bestPerformance = currPerformance;
    elseif currPerformance == bestPerformance
        bestChoose = cat(1,bestChoose,currChoose);
        bestPerformance = cat(1,bestPerformance,currPerformance);
    end
    currChoose = nextChooseFn();
    notFinished = ~finishedFunction(currChoose);
    iterationCount = iterationCount + 1;
    
    if ~ishandle(h)
        canceled = true;
        break
    end
end

if PrtFeatSelOpt.showProgressBar && ~canceled
    delete(h);
end
drawnow;

if size(bestChoose,1) > 1
    warning('prt:exaustiveSetsTie','Multiple identical performing feature sets found with performance %f; randomly selecting one feature set for output',bestPerformance(1));
    index = max(ceil(rand*size(bestChoose,1)),1);
    bestChoose = bestChoose(index,:);
    bestPerformance = bestPerformance(index,:);
end
prtFeatSelector.performance = bestPerformance;
prtFeatSelector.selectedFeatures = bestChoose;
prtFeatSelector.PrtOptions = PrtFeatSelOpt;