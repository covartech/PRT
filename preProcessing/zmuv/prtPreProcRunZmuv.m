function DataSetOut = prtPreProcRunZmuv(PrtZmuv,DataSetIn)
%DataSet = prtPreProcRunZmuv(PrtZmuv,DataSet)

DataSetOut = prtDataSet(DataSetIn,'data',bsxfun(@rdivide,bsxfun(@minus,DataSetIn.data,PrtZmuv.mean),PrtZmuv.stdev));