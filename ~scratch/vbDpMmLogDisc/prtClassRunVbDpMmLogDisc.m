function [ClassifierResults,Etc] = prtClassRunVbDpMmLogDisc(C,DS)
%%

ClassifierResults = prtDataSet(logDiscPredictiveProb(DS.getObservations(),C.Q));

Etc = [];