function pf = prtScorePfAtPdKfolds(DS,PrtClassObj,pdDesired,nFolds)
%pf = prtScorePfAtPdKfolds(DS,PrtClassObj,pdDesired,nFolds)
%
%   Note: use 1-prtScorePfAtPdKfolds(...) for optimization purposes

Results = kfolds(PrtClassObj,DS,nFolds);
[pf,pd] = prtScoreRoc(Results.getObservations,DS.getTargets);

[pd,sortInd] = sort(pd(:),'ascend');
pf = pf(sortInd);

[~,ind] = find(pd >= pdDesired);
if ~isempty(ind)
    pf = pf(ind(1));
else
    pf = nan;
end