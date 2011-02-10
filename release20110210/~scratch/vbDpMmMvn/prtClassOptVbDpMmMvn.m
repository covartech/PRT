function PrtClassOpt = prtClassOptVbDpMmMvn

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtClassOpt.Private.classifierName = 'VB DP MM MVN';
PrtClassOpt.Private.classifierNameAbbreviation = 'VbDpMmMvn';
PrtClassOpt.Private.generateFunction = @prtClassGenVbDpMmMvn;
PrtClassOpt.Private.runFunction = @prtClassRunVbDpMmMvn;
PrtClassOpt.Private.supervised = true;
PrtClassOpt.Private.nativeMaryCapable = true;
PrtClassOpt.Private.nativeBinaryCapable = true;
PrtClassOpt.Private.PrtObjectType = 'classifier';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PrtClassOpt.PreProcOpt = {prtPreProcOptDemean prtPreProcOptZmuv};

PrtClassOpt.nMaxGmmClusters = 25;
PrtClassOpt.covarianceStructure = 'diagonal';
