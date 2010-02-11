function [DataSetOut,Etc] = prtPreProcRunDemean(PrtDemean,DataSetIn)
%DataSet = prtPreProcRunZmuv(PrtZmuv,DataSet)

Etc = [];
DataSetOut = DataSetIn.setObservations(bsxfun(@minus,DataSetIn.getObservations,mean(DataSetIn.getObservations,2)));