function PrtClassOpt = prtClassOptVbDpMmLogDiscBag

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtClassOpt.Private.classifierName = 'VB DP MM LogDiscBag';
PrtClassOpt.Private.classifierNameAbbreviation = 'VbDpMmLogDiscBag';
PrtClassOpt.Private.generateFunction = @prtClassGenVbDpMmLogDiscBag;
PrtClassOpt.Private.runFunction = @prtClassRunVbDpMmLogDiscBag;
PrtClassOpt.Private.supervised = true;
PrtClassOpt.Private.nativeMaryCapable = true;
PrtClassOpt.Private.nativeBinaryCapable = true;
PrtClassOpt.Private.PrtObjectType = 'classifier';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PrtClassOpt.nMaxComponents = 25;

PrtClassOpt.VbOptions = vbdpmmbagOptions(logDiscOptions);
PrtClassOpt.VbOptions.verboseText = true;
PrtClassOpt.VbOptions.verbosePlot = false;
PrtClassOpt.VbOptions.approximatelyEqualThreshold = 1e-5;
PrtClassOpt.VbOptions.maxIterations = 100;
PrtClassOpt.VbOptions.repeats = 1;