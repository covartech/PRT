function PrtZmuv = prtPreProcGenZmuv(DataSet,PrtOptions)
%PrtZmuv = prtPreProcGenZmuv(DataSet,PrtOptions)

PrtZmuv.PrtOptions = PrtOptions;

PrtZmuv.stdev = nanstd(DataSet.data,0,1);
PrtZmuv.mean = nanmean(DataSet.data,1);