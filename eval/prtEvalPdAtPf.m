function pd = prtEvalPdAtPf(classifier,dataSet,pfDesired,nFolds)
%pd = prtEvalPdAtPf(classifier,dataSet,pfDesired)
%pd = prtEvalPdAtPf(classifier,dataSet,pfDesired,nFolds)

if nargin < 4 || isempty(nFolds)
    nFolds = 1;
end
results = classifier.kfolds(dataSet,nFolds);

[pf,pd] = prtScoreRoc(results.getObservations,dataSet.getTargets);

[pf,sortInd] = sort(pf(:),'ascend');
pd = pd(sortInd);

ind = find(pf >= pfDesired);
if ~isempty(ind)
    pd = pd(ind(1));
else
    pd = nan;
end