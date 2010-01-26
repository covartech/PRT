function auc = prtScoreAucKfolds(DS,PrtClassOpt,nFolds)
%auc = prtScoreAucKfolds(DS,PrtClassOpt,nFolds)

Results = prtKfolds(DS,PrtClassOpt,nFolds);
[pf,pd,auc] = prtScoreRoc(Results.getObservations,DS.getTargets);