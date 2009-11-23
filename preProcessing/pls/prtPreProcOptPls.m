function PrtPreProcOpt = prtPreProcOptPls

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtPreProcOpt.Private.preProcessName = 'Partial Least Squares';
PrtPreProcOpt.Private.preProcessAbbreviation = 'PLS';
PrtPreProcOpt.Private.generateFunction = @prtPreProcGenPls;
PrtPreProcOpt.Private.runFunction = @prtPreProcRunPls;
PrtPreProcOpt.Private.supervised = true;
PrtPreProcOpt.Private.nativeMaryCapable = true;  %let the classifier worry about that
PrtPreProcOpt.Private.nativeBinaryCapable = true;
PrtPreProcOpt.Private.PrtObjectType = 'preProcessor';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PrtPreProcOpt.nComponents = 3;