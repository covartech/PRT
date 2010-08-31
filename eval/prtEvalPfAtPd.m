function pf = prtEvalPfAtPd(classifier,dataSet,pdDesired,nFolds)
%pf = prtEvalPfAtPd(classifier,dataSet,nFolds)
%
%   Note; use 1-prtEvalPfAtPd(...) for optimization purposes to maximize
%   1-Pf


assert(nargin >= 2,'prt:prtEvalPfAtPd:BadInputs','prtEvalPfAtPd requires two input arguments');
assert(isa(classifier,'prtClass') && isa(dataSet,'prtDataSetBase'),'prt:prtEvalPfAtPd:BadInputs','prtEvalPfAtPd inputs must be sublcasses of prtClass and prtDataSetBase, but input one was a %s, and input 2 was a %s',class(classifier),class(dataSet));

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