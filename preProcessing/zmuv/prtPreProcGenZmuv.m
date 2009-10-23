function PrtZmuv = prtPreProcGenZmuv(DataSet,PrtOptions)
%PrtZmuv = prtPreProcGenZmuv(DataSet,PrtOptions)

PrtZmuv.PrtOptions = PrtOptions;

PrtZmuv.stdev = nanstd(DataSet.getObservations,0,1);
PrtZmuv.mean = nanmean(DataSet.getObservations,1);