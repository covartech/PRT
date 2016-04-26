function logLoss = prtEvalLogLoss(classifier,dataSet,nFolds)
% prtEvalLogLoss    Calculate log-loss after applying classifier to dataSet
% 
%   logLoss = prtEvalLogLoss(prtClassifier, prtDataSet) returns the
%   log-Loss for prtDataSet when classified by prtClassifier. prtDataSet
%   must be a labeled, prtDataSetStandard object. prtClassifier must be a
%   prtClass object.
%
%   logLoss = prtEvalLogLoss(prtClassifier, prtDataSet, nFolds)  returns
%   the log-Loss of prtDataSet when classified by prtClassifier with K-fold
%   cross-validation. prtDataSet must be a labeled, prtDataSetStandard
%   object. prtClassifier must be a prtClass object. nFolds is the number
%   of folds in the K-fold cross-validation.
%
%   logLoss = prtEvalLogLoss(prtClassifier, prtDataSet, xValInds) same as
%   above, but use crossValidation with specified indices instead of random
%   folds.
%
%       Note: since a lower log-loss is better, if log-loss is used in
%       feature selection, for example, you should optimize over the *negative*
%       log-loss.
% 
%   See the help for prtScoreLogLoss for more information.
%
%   Example:
%   dataSet = prtDataGenSpiral;
%   classifier = prtClassDlrt;
%   ll = prtEvalLogLoss(classifier, dataSet)
%
%   See Also: prtScoreLogLoss, prtEvalPdAtPf, prtEvalPfAtPd, prtEvalAuc, 
%   prtEvalMinCost, prtEvalPercentCorrect






if nargin < 3 || isempty(nFolds)
    nFolds = 1;
end
results = prtUtilEvalParseAndRun(classifier,dataSet,nFolds);
logLoss = prtScoreLogLoss(results);
