function PrtClassOpt = prtClassOptLVQ
%PrtClassOpt = prtClassOptLVQ
%   Generate options structure for learning-vector-quantization
%   classification.
%
%   Primary options for classification are inside
%   PrtClassOpt.PrtUtilOptFuzzyKmeans, which specifies the Fuzzy-K-Means
%   parameters used in prototype generation, and the parameter
%   learningRate which specifies a function handle taking one input
%   argument (the iteration number) and outputting the current learning
%   rate.  Learning rate should be a monotonically decreasing function of
%   it's one input argument.  For example:
%
%   PrtClassOpt.learningRate = @(iteration) exp(-iteration);
%
%   PrtClassOpt.maxIterations specifies the maximum number of iterations to
%   utilize.
%
%   See: Hastie, Tibshirani, Friedman, "The Elements of Statistical
%   Learning", Chappter 13, p. 414.

% Peter Torrione

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtClassOpt.Private.classifierName = 'Learning Vector Quantization';
PrtClassOpt.Private.classifierNameAbbreviation = 'LVQ';
PrtClassOpt.Private.generateFunction = @prtClassGenLVQ;
PrtClassOpt.Private.runFunction = @prtClassRunLVQ;
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

PrtClassOpt.learningRate = @(iteration) exp(-iteration/100);
PrtClassOpt.maxIterations = 1000;

PrtClassOpt.PrtUtilOptFuzzyKmeans = prtUtilOptFuzzyKmeans;
% Plotting Options
PrtClassOpt.PlotOptions = prtPlotOpt;
