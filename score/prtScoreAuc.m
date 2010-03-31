function auc = prtScoreAuc(DS,PrtClassObj)
%auc = prtScoreAuc(DS,PrtClassOpt)

Results = run(PrtClassObj.train(DS),DS);
[~,~,auc] = prtScoreRoc(Results.getObservations,DS.getTargets);