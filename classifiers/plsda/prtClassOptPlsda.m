function PrtClassOpt = prtClassOptPlsda
%PrtClassOpt = prtClassOptPlsda

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtClassOpt.Private.classifierName = 'Partial Least Squares Discriminant Analysis';
PrtClassOpt.Private.classifierNameAbbreviation = 'PLSDA';
PrtClassOpt.Private.generateFunction = @prtClassGenPlsda;
PrtClassOpt.Private.runFunction = @prtClassRunPlsda;
PrtClassOpt.Private.supervised = true;
PrtClassOpt.Private.nativeMaryCapable = true;
PrtClassOpt.Private.nativeBinaryCapable = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PrtClassOpt.twoClassParadigm = 'binary';
Options.MaryEmulationOptions = [];
Options.BinaryEmulationOptions = optionsBinaryEmulationOptionsNone;

PrtClassOpt.nComponents = 2;

% Plotting Options
PrtClassOpt.PlotOptions = prtPlotOpt;



