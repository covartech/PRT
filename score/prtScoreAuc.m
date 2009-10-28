function auc = prtScoreAuc(DS,PrtClassOpt)
%auc = prtScoreAuc(DS,PrtClassOpt)

Results = prtRun(prtGenerate(DS,PrtClassOpt),DS);
[pf,pd,auc] = prtScoreRoc(Results.getObservations,DS.getTargets);