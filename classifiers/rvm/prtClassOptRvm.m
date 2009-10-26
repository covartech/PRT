function PrtClassOpt = prtClassOptRvm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtClassOpt.Private.classifierName = 'Relevance Vector Machine';
PrtClassOpt.Private.classifierNameAbbreviation = 'RVM';
PrtClassOpt.Private.generateFunction = @prtClassGenRvm;
PrtClassOpt.Private.runFunction = @prtClassRunRvm;
PrtClassOpt.Private.supervised = true;
PrtClassOpt.Private.nativeMaryCapable = false;
PrtClassOpt.Private.nativeBinaryCapable = true;
PrtClassOpt.Private.PrtObjectType = 'classifier';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PrtClassOpt.kernel = {@(x1,x2)prtKernelDc(x1,x2),@(x1,x2) prtKernelRbfNdimensionScale(x1,x2,1)};
PrtClassOpt.Laplacian.maxIterations = 1000;
PrtClassOpt.Laplacian.thetaTol = 1e-3;
PrtClassOpt.Laplacian.gNorm = 1e-1;
PrtClassOpt.Laplacian.deltaThetaNormTol = 1e-7;