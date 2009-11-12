function [ClassifierResults,Etc] = prtClassRunPlsda(PrtClassPlsda,PrtDataSetIn)
%[ClassifierResults,Etc] = prtClassRunPlsda(PrtDataSet,PrtClassOpt)

Etc = [];
Yout = bsxfun(@plus,PrtDataSetIn.getObservations*PrtClassPlsda.Bpls, PrtClassPlsda.yMeans - PrtClassPlsda.xMeans*PrtClassPlsda.Bpls);
ClassifierResults = prtDataSet(Yout);

