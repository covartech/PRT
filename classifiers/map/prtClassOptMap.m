% function PrtClassOpt = prtClassOptMap
% %PrtClassOpt = prtClassOptMap
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PrtClassOpt.Private.classifierName = 'Maximum a Posteriori';
% PrtClassOpt.Private.classifierNameAbbreviation = 'MAP';
% PrtClassOpt.Private.generateFunction = @prtClassGenMap;
% PrtClassOpt.Private.runFunction = @prtClassRunMap;
% PrtClassOpt.Private.supervised = true;
% PrtClassOpt.Private.nativeMaryCapable = true;
% PrtClassOpt.Private.nativeBinaryCapable = true;
% PrtClassOpt.Private.PrtObjectType = 'classifier';
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% PrtClassOpt.rvs = prtRvMvn;
% 
% % Mary, Binary Conversion Functions
% PrtClassOpt.twoClassParadigm = 'binary';
% PrtClassOpt.MaryEmulationOptions = [];
% PrtClassOpt.BinaryEmulationOptions = [];
% 
% % Plotting Options
% PrtClassOpt.PlotOptions = prtPlotOpt;


function PrtClassOpt = prtClassOptMap
%PrtClassOpt = prtClassOptMap

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtClassOpt.Private.classifierName = 'Maximum a Posteriori';
PrtClassOpt.Private.classifierNameAbbreviation = 'MAP';
PrtClassOpt.Private.generateFunction = @prtClassGenMap;
PrtClassOpt.Private.runFunction = @prtClassRunMap;
PrtClassOpt.Private.supervised = true;
PrtClassOpt.Private.nativeMaryCapable = true;
PrtClassOpt.Private.nativeBinaryCapable = true;
PrtClassOpt.Private.PrtObjectType = 'classifier';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PrtClassOpt.rvs = prtRvMvn;

% Mary, Binary Conversion Functions
PrtClassOpt.twoClassParadigm = 'binary';
PrtClassOpt.MaryEmulationOptions = [];
PrtClassOpt.BinaryEmulationOptions = [];

% Plotting Options
PrtClassOpt.PlotOptions = prtPlotOpt;


