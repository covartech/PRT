function [DataSetOut,Etc] = prtPreProcRunPls(PrtLda,DataSetIn)
%[DataSetOut,Etc] = prtPreProcGenPls(PrtDataSet,PrtOptions)

Etc = [];
X = DataSetIn.getObservations;
DataSetOut = DataSetIn.setObservations(X*PrtLda.projectionMatrix');