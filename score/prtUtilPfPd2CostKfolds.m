function cost = prtUtilPfPd2CostKfolds(DS,PrtClass,nFolds,costMatrix)
%cost = prtUtilPfPd2CostKfolds(DS,PrtClassOpt,nFolds)

Results = kfolds(PrtClass,DS,nFolds);
[pf,pd] = prtScoreRoc(Results.getObservations,DS.getTargets);
cost = prtUtilPfPd2Cost(pf,pd,costMatrix);
cost = min(cost);