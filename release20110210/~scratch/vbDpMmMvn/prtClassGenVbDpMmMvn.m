function C = prtClassGenVbDpMmMvn(DS,PrtOptions)
%C = prtClassGenVbDpMmMvn(DS,PrtOptions)


C.PrtOptions = PrtOptions;
C.PrtDataSet = DS;


C.uY = unique(DS.getTargets());

C.PreProc = prtGenerate(DS, C.PrtOptions.PreProcOpt);
PreProcDS = prtRun(C.PreProc,DS);

for iY = 1:length(C.uY)
    C.GmmQs{iY} = ezDpMmPriorAlpha(PreProcDS.getObservationsByClassInd(iY),C.PrtOptions.nMaxGmmClusters,C.PrtOptions.covarianceStructure);
end