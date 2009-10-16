function PrtClassOpt = prtClassOptRvmJeffreys

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtClassOpt.Private.classifierName = 'Relevance Vector Machine (Jeffrey''s Prior)';
PrtClassOpt.Private.classifierNameAbbreviation = 'RVM_{Jeffreys}';
PrtClassOpt.Private.generateFunction = @prtClassGenRvmJeffreys;
PrtClassOpt.Private.runFunction = @prtClassRunRvmJeffreys;
PrtClassOpt.Private.supervised = true;
PrtClassOpt.Private.nativeMaryCapable = false;
PrtClassOpt.Private.nativeBinaryCapable = true;
PrtClassOpt.Private.PrtObjectType = 'classifier';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PrtClassOpt.kernel = {@(x1,x2)prtKernelDc(x1,x2),@(x1,x2) prtKernelRbf(x1,x2,1)};
PrtClassOpt.Jeffereys.maxIterations = 1000;
PrtClassOpt.Jeffereys.betaConvergedTolerance = 1e-3;
PrtClassOpt.Jeffereys.betaRelevantTolerance = 1e-3;