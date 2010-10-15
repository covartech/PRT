function C = prtClassGenVbDpMmLogDisc(DS,PrtOptions)
% C = prtClassGenVbDpMmLogDisc(DS,PrtOptions)

C.PrtOptions = PrtOptions;
C.PrtDataSet = DS;

%%
SourcePrior = logDiscPrior(DS.nFeatures);
P = vbdpmmPrior(C.PrtOptions.nMaxComponents ,SourcePrior);

C.Q = vbdpmm(cat(2,DS.getTargets(),DS.getObservations()),P,C.PrtOptions.VbOptions);

%%

