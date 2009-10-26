function [DataSetOut,Etc] = prtPreProcRunZmuv(PrtZmuv,DataSetIn)
%DataSet = prtPreProcRunZmuv(PrtZmuv,DataSet)

Etc = [];
DataSetOut = prtDataSet(bsxfun(@rdivide,bsxfun(@minus,DataSetIn.getObservations,PrtZmuv.mean),PrtZmuv.stdev),DataSetIn.getTargets);