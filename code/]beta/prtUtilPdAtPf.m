function pdHit = prtUtilPdAtPf(pf,pd,pfGoal)
%pdHit = prtUtilPdAtPf(pf,pd,pfGoal)
% 

ind = find(pf > pfGoal,1,'first');
pdHit = pd(ind);