function Options = prtClassOptLogDisc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Options.Private.classifierName = 'Logistic Discriminant';
Options.Private.classifierNameAbbreviation = 'LogDisc';
Options.Private.generateFunction = @prtClassGenLogDisc;
Options.Private.runFunction = @prtClassRunLogDisc;
Options.Private.supervised = true;
Options.Private.nativeMaryCapable = false;
Options.Private.nativeBinaryCapable = true;
Options.Private.PrtObjectType = 'classifier';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Options.handleNonPosDefR = 'exit'; %'regularize'

Options.twoClassParadigm = 'binary';
Options.PlotOptions = optionsDprtPlot;
Options.MaryEmulationOptions = [];

%Options.irlsStepSize = 'hessian';
Options.irlsStepSize = .05;

Options.maxIter = 500;
Options.wInit = 'FLD';
Options.wTolerance = 1e-2;
