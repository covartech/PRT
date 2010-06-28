function pd = prtScorePdAtPfKfolds(DS,PrtClassObj,pfDesired,nFolds)
%pd = prtScorePdAtPfKfolds(DS,PrtClassObj,pdDesired,nFolds)
%

Results = kfolds(PrtClassObj,DS,nFolds);
[pf,pd] = prtScoreRoc(Results.getObservations,DS.getTargets);
[pf,sortInd] = sort(pf(:),'ascend');
pd = pd(sortInd);

[~,ind] = find(pf >= pfDesired);
if ~isempty(ind)
    pd = pd(ind(1));
else
    pd = nan;
end