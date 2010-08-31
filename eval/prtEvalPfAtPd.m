function pf = prtEvalPfAtPd(classifier,dataSet,pdDesired,nFolds)
%pf = prtEvalPfAtPd(classifier,dataSet,nFolds)
%
%   Note; use 1-prtEvalPfAtPd(...) for optimization purposes to maximize
%   1-Pf

if nargin < 4 || isempty(nFolds)
    nFolds = 1;
end
results = classifier.kfolds(dataSet,nFolds);

[pf,pd] = prtScoreRoc(results.getObservations,dataSet.getTargets);
[pd,sortInd] = sort(pd(:),'ascend');
pf = pf(sortInd);

ind = find(pd >= pdDesired);
if ~isempty(ind)
    pf = pf(ind(1));
else
    pf = nan;
end