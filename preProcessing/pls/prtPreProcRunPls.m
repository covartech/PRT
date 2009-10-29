function [DataSetOut,Etc] = prtPreProcRunPls(PrtPls,DataSetIn)
%[DataSetOut,Etc] = prtPreProcGenPls(PrtDataSet,PrtOptions)

Etc = [];
X = DataSetIn.getObservations;
X = bsxfun(@minus,X,PrtPls.meanX);
DataSetOut = DataSetIn.setObservations(X*PrtPls.projectionMatrix);