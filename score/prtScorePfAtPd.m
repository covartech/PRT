function pf = prtScorePfAtPd(DS,PrtClassObj,pdDesired)
%pf = prtScorePfAtPd(DS,PrtClassObj,pdDesired)
%
%  Note: use 1-prtScorePfAtPd(...) for optimization purposes

Results = run(PrtClassObj.train(DS),DS);
[pf,pd] = prtScoreRoc(Results.getObservations,DS.getTargets);
[pd,sortInd] = sort(pd(:),'ascend');
pf = pf(sortInd);

[~,ind] = find(pd >= pdDesired);
if ~isempty(ind(1))
    pf = pf(ind);
else
    pf = nan;
end