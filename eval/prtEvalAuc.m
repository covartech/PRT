function auc = prtEvalAuc(classifier,dataSet,nFolds)
% prtEvalPfAtPd   Returns the area under the receiver operating curve.
%
%   PF = prtEvalAuc(CLASSIFIER, DATASET) returns the area under the
%   receiver operating curve. DATASET must be a labeled, binary
%   prtDataSetStandard object. CLASSIFIER must be a prtClass object. 
%
%   PF = prtScoreAucKfolds(CLASSIFIER, DATASET, NFOLDS) returns the area
%   under the receiver operating curve with K-fold cross-validation.
%   DATASET must be a labeled, binary prtDataSetStandard object. CLASSIFIER
%   must be a prtClass object. NFOLDS is the number of folds in the K-fold
%   cross-validation.
%
%   Example:
%   dataSet = prtDataGenSpiral;
%   classifier = prtClassDlrt;
%   pf =  prtEvalAuc(classifier, dataSet)
%
%   See Also: prtEvalPdAtPf, prtEvalPfAtPd, prtEvalPercentCorrect,
%   prtEvalMinCost

%prtEvalAuc   Score by the area under curve method
%
%   auc = prtEvalAuc(class,dataSet)
%   auc = prtEvalAuc(class,dataSet,nFolds)

assert(nargin >= 2,'prt:prtEvalAuc:BadInputs','prtEvalAuc requires two input arguments');
assert(isa(classifier,'prtClass') && isa(dataSet,'prtDataSetBase'),'prt:prtEvalAuc:BadInputs','prtEvalAuc inputs must be sublcasses of prtClass and prtDataSetBase, but input one was a %s, and input 2 was a %s',class(classifier),class(dataSet));

if nargin < 3 || isempty(nFolds)
    nFolds = 1;
end
Results = classifier.kfolds(dataSet,nFolds);
[~,~,auc] = prtScoreRoc(Results.getObservations,dataSet.getTargets);