function [DataSetOut,Etc] = prtPreProcRunOutRem(PrtOutRem,DataSetIn)
%DataSet = prtPreProcRunZmuv(PrtZmuv,DataSet)

Etc = [];

obsToRemove = any(bsxfun(@gt,abs(bsxfun(@minus,DataSetIn.getObservations,PrtOutRem.mean)),PrtOutRem.PrtOptions.nStdsAwayToCut * PrtOutRem.stdev),2);

DataSetOut = DataSetIn.removeObservations(obsToRemove);