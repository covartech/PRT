function auc = prtEvalAuc(classifier,dataSet,nFolds)
% prtEvalAuc   Returns the area under the receiver operating curve.
%
%   auc = prtEvalAuc(CLASSIFIER, DATASET) returns the area under the
%   receiver operating curve. DATASET must be a labeled, binary
%   prtDataSetStandard object. CLASSIFIER must be a prtClass object. 
%
%   auc = prtScoreAuc(CLASSIFIER, DATASET, NFOLDS) returns the area
%   under the receiver operating curve with K-fold cross-validation.
%   DATASET must be a labeled, binary prtDataSetStandard object. CLASSIFIER
%   must be a prtClass object. NFOLDS is the number of folds in the K-fold
%   cross-validation.
%
%   Example:
%   dataSet = prtDataGenSpiral;
%   classifier = prtClassDlrt;
%   auc = prtEvalAuc(classifier, dataSet)
%
%   See Also: prtEvalPdAtPf, prtEvalPfAtPd, prtEvalPercentCorrect,
%   prtEvalMinCost

assert(nargin >= 2,'prt:prtEvalAuc:BadInputs','prtEvalAuc requires two input arguments');
assert(isa(classifier,'prtAction') && isa(dataSet,'prtDataSetBase'),'prt:prtEvalAuc:BadInputs','prtEvalAuc inputs must be sublcasses of prtClass and prtDataSetBase, but input one was a %s, and input 2 was a %s',class(classifier),class(dataSet));

if nargin < 3 || isempty(nFolds)
    nFolds = 1;
end

Results = classifier.kfolds(dataSet,nFolds);
auc = prtScoreAuc(Results.getObservations,dataSet.getTargets);