function PrtRegOpt = prtRegOptLadIrls

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtRegOpt.Private.regressionName = 'Least Absolute Deviations Regression';
PrtRegOpt.Private.regressionNameAbbreviation = 'LAD';
PrtRegOpt.Private.generateFunction = @prtRegGenLadIrls;
PrtRegOpt.Private.runFunction = @prtRegRunLadIrls;
PrtRegOpt.Private.supervised = true;
PrtRegOpt.Private.PrtObjectType = 'regressor';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
