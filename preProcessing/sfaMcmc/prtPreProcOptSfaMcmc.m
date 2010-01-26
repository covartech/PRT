function PrtPreProcOpt = prtPreProcOptSfaMcmc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtPreProcOpt.Private.preProcessName = 'Sparse Factor Analysis (MCMC)';
PrtPreProcOpt.Private.preProcessAbbreviation = 'SfaMcmc';
PrtPreProcOpt.Private.generateFunction = @prtPreProcGenSfaMcmc;
PrtPreProcOpt.Private.runFunction = @prtPreProcRunSfaMcmc;
PrtPreProcOpt.Private.supervised = false;
PrtPreProcOpt.Private.nativeMaryCapable = true;  %let the classifier worry about that
PrtPreProcOpt.Private.nativeBinaryCapable = true;
PrtPreProcOpt.Private.PrtObjectType = 'preProcessor';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PrtPreProcOpt.Mcmc.nBurin = 300;
PrtPreProcOpt.Mcmc.nSamples = 300;

PrtPreProcOpt.piThreshold = 0.1;

priorVal = eps;
PrtPreProcOpt.Prior.c = 1;
PrtPreProcOpt.Prior.d = priorVal;
PrtPreProcOpt.Prior.e = priorVal;
PrtPreProcOpt.Prior.f = priorVal;
PrtPreProcOpt.Prior.g = priorVal;
PrtPreProcOpt.Prior.h = priorVal;

PrtPreProcOpt.Prior.alpha = 30;
PrtPreProcOpt.Prior.beta =  30;

PrtPreProcOpt.maxComponents = 60;
PrtPreProcOpt.maxPr = 1e20;  %numerical stability issues
PrtPreProcOpt.displayOnIter = 1;