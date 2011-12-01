function [pfAtPd1, threshold] = prtUtilPfAtPd1(pf,pd,ds)
% [pfAtPd1, threshold] = prtUtilPfAtPd1(pf,pd,ds)
% xxx Need Help xxx

pf = pf(:);
pd = pd(:);

keyboard

[pf,sortInd] = sort(pf,'ascend');
pd = pd(sortInd);

pf(end+1) = maxPfVal + eps;
pd(end+1) = pd(end);

firstInd = find(pf > maxPfVal,1,'first');

pf = pf(1:firstInd);
pd = pd(1:firstInd);

