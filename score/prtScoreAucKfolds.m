function auc = prtScoreAucKfolds(DS,PrtClass,nFolds)
%auc = prtScoreAucKfolds(DS,PrtClassOpt,nFolds)

Results = kfolds(PrtClass,DS,nFolds);
[~,~,auc] = prtScoreRoc(Results.getObservations,DS.getTargets);