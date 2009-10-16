function PrtClassOpt = prtClassOptFld
%PrtClassOpt = prtClassOptFld

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtClassOpt.Private.classifierName = 'Fisher Linear Discriminant';
PrtClassOpt.Private.classifierNameAbbreviation = 'FLD';
PrtClassOpt.Private.generateFunction = @prtClassGenFld;
PrtClassOpt.Private.runFunction = @prtClassRunFld;
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


