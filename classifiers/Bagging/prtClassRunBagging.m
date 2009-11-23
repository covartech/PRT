function [Results,Etc] = prtClassRunBagging(Classifier,Data)

Etc = [];
yOut = 0;
for i = 1:Classifier.PrtOptions.nBags
    Results = prtRun(Classifier.Classifiers(i),Data);
    yOut = yOut + Results.getObservations;
end
Results = Data.setObservations(yOut./Classifier.PrtOptions.nBags);