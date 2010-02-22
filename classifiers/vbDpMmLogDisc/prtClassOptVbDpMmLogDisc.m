function PrtClassOpt = prtClassOptVbDpMmLogDisc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtClassOpt.Private.classifierName = 'VB DP MM LogDisc';
PrtClassOpt.Private.classifierNameAbbreviation = 'VbDpMmLogDisc';
PrtClassOpt.Private.generateFunction = @prtClassGenVbDpMmLogDisc;
PrtClassOpt.Private.runFunction = @prtClassRunVbDpMmLogDisc;
PrtClassOpt.Private.supervised = true;
PrtClassOpt.Private.nativeMaryCapable = true;
PrtClassOpt.Private.nativeBinaryCapable = true;
PrtClassOpt.Private.PrtObjectType = 'classifier';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PrtClassOpt.nMaxComponents = 25;

PrtClassOpt.VbOptions = vbdpmmOptions(logDiscOptions);
PrtClassOpt.VbOptions.verboseText = false;
PrtClassOpt.VbOptions.verbosePlot = false;
PrtClassOpt.VbOptions.approximatelyEqualThreshold = 1e-5;
PrtClassOpt.VbOptions.maxIterations = 200;
PrtClassOpt.VbOptions.repeats = 5;