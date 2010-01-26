function PrtPreProcOpt = prtPreProcOptSpca

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtPreProcOpt.Private.preProcessName = 'Sparse PCA';
PrtPreProcOpt.Private.preProcessAbbreviation = 'SPCA';
PrtPreProcOpt.Private.generateFunction = @prtPreProcGenSpca;
PrtPreProcOpt.Private.runFunction = @prtPreProcRunSpca;
PrtPreProcOpt.Private.supervised = false;
PrtPreProcOpt.Private.nativeMaryCapable = true;  %let the classifier worry about that
PrtPreProcOpt.Private.nativeBinaryCapable = true;
PrtPreProcOpt.Private.PrtObjectType = 'preProcessor';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PrtPreProcOpt.nComponents = 3;
PrtPreProcOpt.lambda = 2000;
PrtPreProcOpt.maxIter = 10000;

PrtPreProcOpt.Display.plotOnIter = 100;
PrtPreProcOpt.Convergence.normPercentThreshold = 1e-3;