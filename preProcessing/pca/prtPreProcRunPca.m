function [DataSetOut,Etc] = prtPreProcRunPca(PrtPca,DataSetIn)
%DataSet = prtPreProcRunPca(PrtPca,DataSetIn)

Etc = [];
X = DataSetIn.getObservations;
X = bsxfun(@minus,X,PrtPca.means);
DataSetOut = DataSetIn.setObservations(X*PrtPca.pcaVectors);