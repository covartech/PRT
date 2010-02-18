function PrtRegOpt = prtRegOptRvmJeffreys

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtRegOpt.Private.regressionName = 'Relevance Vector Machine (Jeffrey''s Prior)';
PrtRegOpt.Private.regressionNameAbbreviation = 'RVM_{Jeffreys}';
PrtRegOpt.Private.generateFunction = @prtRegGenRvmJeffreys;
PrtRegOpt.Private.runFunction = @prtRegRunRvmJeffreys;
PrtRegOpt.Private.supervised = true;
PrtRegOpt.Private.PrtObjectType = 'regressor';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PrtRegOpt.kernel = {@(x1,x2)prtKernelDc(x1,x2),@(x1,x2) prtKernelRbfNdimensionScale(x1,x2,1)};
PrtRegOpt.Jeffereys.maxIterations = 1000;
PrtRegOpt.Jeffereys.betaConvergedTolerance = 1e-3;
PrtRegOpt.Visualization.plotting = false;