function PrtOptions = prtClassOptBagging(ClassifierOptions)

if nargin == 0
    error('prtClassOptBagging requires input classifierOptions');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtOptions.Private.classifierName = 'Bagging';
PrtOptions.Private.classifierNameAbbreviation = 'Bagging';
PrtOptions.Private.generateFunction = @prtClassGenBagging;
PrtOptions.Private.runFunction = @prtClassRunBagging;
PrtOptions.Private.supervised = true;
PrtOptions.Private.nativeMaryCapable = true;
PrtOptions.Private.nativeBinaryCapable = true;
PrtOptions.Private.PrtObjectType = 'classifier';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PrtOptions.ClassifierOptions = ClassifierOptions;
PrtOptions.nBags = 10;

PrtOptions.twoClassParadigm = 'binary';
PrtOptions.PlotOptions = optionsDprtPlot;
PrtOptions.MaryEmulationOptions = [];