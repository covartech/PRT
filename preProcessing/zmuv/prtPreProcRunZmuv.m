function [DataSetOut,Etc] = prtPreProcRunZmuv(PrtZmuv,DataSetIn)
%DataSet = prtPreProcRunZmuv(PrtZmuv,DataSet)

Etc = [];
DataSetOut = DataSetIn.setObservations(bsxfun(@rdivide,bsxfun(@minus,DataSetIn.getObservations,PrtZmuv.mean),PrtZmuv.stdev));