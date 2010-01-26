function PrtRegOpt = prtRegOptLslr

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtRegOpt.Private.regressionName = 'Least-Squares Linear Regression';
PrtRegOpt.Private.regressionNameAbbreviation = 'LSLR';
PrtRegOpt.Private.generateFunction = @prtRegGenLslr;
PrtRegOpt.Private.runFunction = @prtRegRunLslr;
PrtRegOpt.Private.supervised = true;
PrtRegOpt.Private.PrtObjectType = 'regressor';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
