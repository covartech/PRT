function pd = prtEvalPdAtPf(classifier,dataSet,pfDesired,nFolds)
% prtEvalPdAtPf   Returns the probability of false alarm at a desired
%   probability of detection on the receiver operating curve.
%
%   PD = prtEvalPdAtPf(prtClassifier, prtDataSet, pfDesired) returns the
%   probabilty of detection PD.  prtDataSet must be a labeled, binary
%   prtDataSetStandard object. prtClassifier must be a prtClass object.
%   pfDesired is the desired probability of false alarm and must be between
%   0 and 1.
%
%   pfDesired = prtEvalPdAtPf(prtClassifier, prtDataSet, pfDesired, nFolds)
%   returns the probabilty of false alarm pfDesired on the receiver
%   operating curve with K-fold cross-validation. prtDataSet must be a
%   labeled, binary prtDataSetStandard object. prtClassifier must be a
%   prtClass object. pfDesired is the desired probability of detection and
%   must be between 0 and 1. nFolds is the number of folds in the K-fold
%   cross-validation.
%
%   pfDesired = prtEvalPdAtPf(prtClassifier, prtDataSet, pfDesired,
%   xValInds) same as above, but use crossValidation with specified indices
%   instead of random folds.
%
%   Example: 
%   dataSet = prtDataGenSpiral; 
%   classifier = prtClassDlrt;
%   pf = prtEvalPdAtPf(classifier, dataSet,.01)
%
%   See Also: prtEvalAuc, prtEvalPfAtPd, prtEvalPercentCorrect,
%   prtEvalMinCost







if nargin < 4 || isempty(nFolds)
    nFolds = 1;
end
results = prtUtilEvalParseAndRun(classifier,dataSet,nFolds);

[pf,pd] = prtScoreRoc(results.getObservations,dataSet.getTargets);

[pf,sortInd] = sort(pf(:),'ascend');
pd = pd(sortInd);

ind = find(pf >= pfDesired);
if ~isempty(ind)
    pd = pd(ind(1));
else
    pd = nan;
end
