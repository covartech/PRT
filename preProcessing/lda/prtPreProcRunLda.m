function [DataSetOut,Etc] = prtPreProcRunLda(PrtLda,DataSetIn)
%DataSet = prtPreProcRunLda(PrtLda,DataSetIn)

Etc = [];
X = DataSetIn.getObservations;
X = bsxfun(@minus,X,PrtLda.globalMean);
DataSetOut = DataSetIn.setObservations(X*PrtLda.projectionMatrix);