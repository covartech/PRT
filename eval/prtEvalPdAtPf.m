function pd = prtEvalPdAtPf(classifier,dataSet,pfDesired,nFolds)
%pd = prtEvalPdAtPf(classifier,dataSet,pfDesired)
%pd = prtEvalPdAtPf(classifier,dataSet,pfDesired,nFolds)

assert(nargin >= 2,'prt:prtEvalPdAtPf:BadInputs','prtEvalPdAtPf requires two input arguments');
assert(isa(classifier,'prtClass') && isa(dataSet,'prtDataSetBase'),'prt:prtEvalPdAtPf:BadInputs','prtEvalPdAtPf inputs must be sublcasses of prtClass and prtDataSetBase, but input one was a %s, and input 2 was a %s',class(classifier),class(dataSet));

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