function PrtPreProcOpt = prtPreProcOptDemean

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtPreProcOpt.Private.preProcessName = 'Demean Observations';
PrtPreProcOpt.Private.preProcessAbbreviation = 'Demean';
PrtPreProcOpt.Private.generateFunction = @prtPreProcGenDemean;
PrtPreProcOpt.Private.runFunction = @prtPreProcRunDemean;
PrtPreProcOpt.Private.supervised = true;
PrtPreProcOpt.Private.nativeMaryCapable = true;  %let the classifier worry about that
PrtPreProcOpt.Private.nativeBinaryCapable = true;
PrtPreProcOpt.Private.PrtObjectType = 'preProcessor';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

