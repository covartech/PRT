function [cost,pf,pd] = prtScoreCost(ds,y,costMatrix)
%cost = prtScoreCost(ds,y,costMatrix)
%[cost,pf,pd] = prtScoreCost(ds,y,costMatrix)

[ds,y] = prtUtilScoreParseFirstTwoInputs(ds,y);
[pf,pd] = prtScoreRoc(ds,y);
cost = prtUtilPfPd2Cost(pf,pd,costMatrix);
