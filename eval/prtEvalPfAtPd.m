function pf = prtEvalPfAtPd(classifier,dataSet,pdDesired,nFolds)
% prtEvalPfAtPd   Returns the probability of detection at a desired
% probability of false alarm on the receiver operating curve.
%
%   PD = prtEvalPfAtPd(CLASSIFIER, DATASET,PF) returns the probabilty of
%   detection PD.  DATASET must be a labeled, binary prtDataSetStandard
%   object. CLASSIFIER must be a prtClass object. PF is the desired
%   probability of detection and must be between 0 and 1.
%
%   PF = prtScorePfAtPd(CLASSIFIER, DATASET,PD, NFOLDS) returns the
%   probabilty of false alarm PF on the receiver operating curve with
%   K-fold cross-validation. DATASET must be a labeled, binary
%   prtDataSetStandard object. CLASSIFIER must be a prtClass object. PF is
%   the desired probability of detection and must be between 0 and 1.
%   NFOLDS is the number of folds in the K-fold cross-validation.
%
%   Example: 
%   dataSet = prtDataGenSpiral; 
%   classifier = prtClassDlrt;
%   pf = prtEvalPdAtPf(classifier, dataSet,.01)
%
%   See Also: prtEvalAuc, prtEvalPfAtPd, prtEvalPercentCorrect,
%   prtEvalMinCost

assert(nargin >= 2,'prt:prtEvalPfAtPd:BadInputs','prtEvalPfAtPd requires two input arguments');
assert(isa(classifier,'prtClass') && isa(dataSet,'prtDataSetBase'),'prt:prtEvalPfAtPd:BadInputs','prtEvalPfAtPd inputs must be sublcasses of prtClass and prtDataSetBase, but input one was a %s, and input 2 was a %s',class(classifier),class(dataSet));

if nargin < 4 || isempty(nFolds)
    nFolds = 1;
end
results = classifier.kfolds(dataSet,nFolds);

[pf,pd] = prtScoreRoc(results.getObservations,dataSet.getTargets);
[pd,sortInd] = sort(pd(:),'ascend');
pf = pf(sortInd);

ind = find(pd >= pdDesired);
if ~isempty(ind)
    pf = pf(ind(1));
else
    pf = nan;
end