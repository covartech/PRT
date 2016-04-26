function auc = prtEvalAuc(classifier,dataSet,nFolds)
% prtEvalAuc   Returns the area under the receiver operating curve.
%
%   auc = prtEvalAuc(prtClassifier, prtDataSet) returns the area under the
%   receiver operating curve. prtDataSet must be a labeled, binary
%   prtDataSetStandard object. prtClassifier must be a prtClass object.
%
%   auc = prtEvalAuc(prtClassifier, prtDataSet, nFolds) returns the area
%   under the receiver operating curve with K-fold cross-validation.
%   prtDataSet must be a labeled, binary prtDataSetStandard object.
%   prtClassifier must be a prtClass object. nFolds is the number of folds
%   in the K-fold cross-validation.
%
%   auc = prtEvalAuc(prtClassifier, prtDataSet, xValInds) same as above,
%   but use crossValidation with specified indices instead of random folds.
%
%   Example:
%   dataSet = prtDataGenSpiral;
%   classifier = prtClassDlrt;
%   auc = prtEvalAuc(classifier, dataSet)
%
%   See Also: prtEvalPdAtPf, prtEvalPfAtPd, prtEvalPercentCorrect,
%   prtEvalMinCost







if nargin < 3 || isempty(nFolds)
    nFolds = 1;
end
Results = prtUtilEvalParseAndRun(classifier,dataSet,nFolds);
auc = prtScoreAuc(Results.getObservations,dataSet.getTargets);
