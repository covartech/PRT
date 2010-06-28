function pd = prtScorePdAtPf(DS,PrtClassObj,pfDesired)
%pd = prtScorePdAtPf(DS,PrtClassObj,pdDesired)
%

Results = run(PrtClassObj.train(DS),DS);
[pf,pd] = prtScoreRoc(Results.getObservations,DS.getTargets);
[pf,sortInd] = sort(pf(:),'ascend');
pd = pd(sortInd);

[~,ind] = find(pf >= pfDesired);
if ~isempty(ind)
    pd = pd(ind(1));
else
    pd = nan;
end