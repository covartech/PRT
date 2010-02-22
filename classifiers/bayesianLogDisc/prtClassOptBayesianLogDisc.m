function PrtClassOpt = prtClassOptBayesianLogDisc
%PrtClassOpt = prtClassOptBayesianLogDisc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtClassOpt.Private.classifierName = 'Bayesian Logistic Discriminant';
PrtClassOpt.Private.classifierNameAbbreviation = 'BLD';
PrtClassOpt.Private.generateFunction = @prtClassGenBayesianLogDisc;
PrtClassOpt.Private.runFunction = @prtClassRunBayesianLogDisc;
PrtClassOpt.Private.supervised = true;
PrtClassOpt.Private.nativeMaryCapable = false;
PrtClassOpt.Private.nativeBinaryCapable = true;
PrtClassOpt.Private.PrtObjectType = 'classifier';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Mary, Binary Conversion Functions
PrtClassOpt.twoClassParadigm = 'binary';
PrtClassOpt.MaryEmulationOptions = [];
PrtClassOpt.BinaryEmulationOptions = optionsBinaryEmulationOptionsNone;

% Plotting Options
PrtClassOpt.PlotOptions = prtPlotOpt;

% Mean of zero, covariance of 5
PrtClassOpt.priorMeanFn = @(numEl) zeros(numEl,1);
PrtClassOpt.priorCovFn = @(numEl) eye(numEl)*.01;
