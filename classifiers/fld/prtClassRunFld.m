function [ClassifierResults,Etc] = prtClassRunFld(PrtClassFld,PrtDataSet)
%[ClassifierResults,Etc] = prtClassRunFld(PrtDataSet,PrtClassOpt)

Etc = [];

y = (PrtClassFld.w'*getObservations(PrtDataSet)')';
ClassifierResults = prtDataSet(y);
