function pd = prtEvalPdAtPf(classifier,dataSet,pfDesired,nFolds)
% prtEvalPfAtPd   Returns the probability of false alarm at a desired
% probability of detection on the receiver operating curve.
%
%   PF = prtEvalPfAtPd(CLASSIFIER, DATASET,PD) returns the probabilty of false
%   alarm PF.  DATASET must be a labeled, binary prtDataSetStandard object.
%   CLASSIFIER must be a prtClass object. PD is the desired probability of
%   detection and must be between 0 and 1.
%
%   PF = prtScorePfAtPd(CLASSIFIER, DATASET,PD, NFOLDS) returns the
%   probabilty of false alarm PF on the receiver operating curve with
%   K-fold cross-validation.  DATASET must be a labeled, binary
%   prtDataSetStandard object. CLASSIFIER must be a prtClass object. PD is
%   the desired probability of detection and must be between 0 and 1.
%   NFOLDS is the number of folds in the K-fold cross-validation.
%
%   Example:
%   dataSet = prtDataGenSpiral;
%   classifier = prtClassDlrt;
%   pf =  prtEvalPfAtPd(classifier, dataSet,.9)
%
%   See Also: prtEvalAuc, prtEvalPfAtPd, prtEvalPercentCorrect,
%   prtEvalMinCost


assert(nargin >= 2,'prt:prtEvalPdAtPf:BadInputs','prtEvalPdAtPf requires two input arguments');
assert(isa(classifier,'prtAction') && isa(dataSet,'prtDataSetBase'),'prt:prtEvalPdAtPf:BadInputs','prtEvalPdAtPf inputs must be sublcasses of prtClass and prtDataSetBase, but input one was a %s, and input 2 was a %s',class(classifier),class(dataSet));

if nargin < 4 || isempty(nFolds)
    nFolds = 1;
end
results = classifier.kfolds(dataSet,nFolds);

[pf,pd] = prtScoreRoc(results.getObservations,dataSet.getTargets);

[pf,sortInd] = sort(pf(:),'ascend');
pd = pd(sortInd);

ind = find(pf >= pfDesired);
if ~isempty(ind)
    pd = pd(ind(1));
else
    pd = nan;
end