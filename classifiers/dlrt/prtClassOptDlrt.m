function PrtOptions = prtClassOptDlrt

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtOptions.Private.classifierName = 'Distance Likelihood Ratio Test';
PrtOptions.Private.classifierNameAbbreviation = 'DLRT';
PrtOptions.Private.generateFunction = @prtClassGenDlrt;
PrtOptions.Private.runFunction = @prtClassRunDlrt;
PrtOptions.Private.supervised = true;
PrtOptions.Private.nativeMaryCapable = false;
PrtOptions.Private.nativeBinaryCapable = true;
PrtOptions.Private.PrtObjectType = 'classifier';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PrtOptions.k = 3;
PrtOptions.distanceFn = @(x1,x2)prtDistance(x1,x2);

PrtOptions.ignoreH0 = false; % Not required default [false]

PrtOptions.twoClassParadigm = 'binary';
PrtOptions.PlotOptions = optionsDprtPlot;
PrtOptions.MaryEmulationOptions = [];