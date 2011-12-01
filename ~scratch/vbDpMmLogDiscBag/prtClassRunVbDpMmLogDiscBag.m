function [ClassifierResults,Etc] = prtClassRunVbDpMmLogDiscBag(C,DS)
%%

[y, yParts] = logDiscBagPredictiveProb(DS.getObservations,C.Q);

ClassifierResults = prtDataSet(y);

Etc.clusterProbs = yParts;