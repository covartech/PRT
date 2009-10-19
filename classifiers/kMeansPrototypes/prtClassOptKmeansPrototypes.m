function PrtClassOpt = prtClassOptKmeansPrototypes
%PrtClassOpt = prtClassOptKmeansPrototypes
%   Generate options structure for K-means prototype classification.
%   Primary options for classification are inside
%   PrtClassOpt.PrtUtilOptFuzzyKmeans, which specifies the Fuzzy-K-Means
%   parameters used in prototype generation.
%
%   See: Hastie, Tibshirani, Friedman, "The Elements of Statistical
%   Learning", Chappter 13, p. 412.

% Peter Torrione


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtClassOpt.Private.classifierName = 'K-Means prototypes';
PrtClassOpt.Private.classifierNameAbbreviation = 'kMeansPrototypes';
PrtClassOpt.Private.generateFunction = @prtClassGenKmeansPrototypes;
PrtClassOpt.Private.runFunction = @prtClassRunKmeansPrototypes;
PrtClassOpt.Private.supervised = true;
PrtClassOpt.Private.nativeMaryCapable = true;
PrtClassOpt.Private.nativeBinaryCapable = true;
PrtClassOpt.Private.PrtObjectType = 'classifier';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Mary, Binary Conversion Functions
PrtClassOpt.twoClassParadigm = 'binary';
PrtClassOpt.MaryEmulationOptions = [];
PrtClassOpt.BinaryEmulationOptions = optionsBinaryEmulationOptionsNone;

PrtClassOpt.PrtUtilOptFuzzyKmeans = prtUtilOptFuzzyKmeans;
% Plotting Options
PrtClassOpt.PlotOptions = prtPlotOpt;


