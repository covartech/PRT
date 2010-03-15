function PrtRegOpt = prtRegOptGp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtRegOpt.Private.name = 'Gaussian Process Regression';
PrtRegOpt.Private.nameAbbreviation = 'GP';
PrtRegOpt.Private.generateFunction = @prtRegGenGp;
PrtRegOpt.Private.runFunction = @prtRegRunGp;
PrtRegOpt.Private.supervised = false;
PrtRegOpt.Private.PrtObjectType = 'regressor';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PrtRegOpt.covarianceFunction = @(x1,x2)prtKernelQuadExpCovariance(x1,x2, 1, 4, 0, 0);
PrtRegOpt.noiseVariance = 0.01;
