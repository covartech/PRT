function auc = prtScoreAucKfolds(DS,PrtClass,nFolds)
%prtScoreAucKfolds   Score by the area under the receiver operating curve
%method with K-fold cross-validation.
%
%   AUC = prtScoreAucKfolds(DS,PRTCLASSOBJ,NFOLDS) returns the area under
%   the receiver operating curve. DS must be a labeled, binary
%   prtDataSetStandard object. PRTCLASSOBJ must be a prtClass object.
%   NFOLDS is the number of folds in the K-fold cross-validation.
%
%   Example:
%   dataSet = prtDataGenSpiral;
%   classifier = prtClassDlrt;
%   prtScoreAucKfolds(dataSet,classifier,10)
%
%   See Also: prtScoreAuc, prtScorePdAtPf, prtScorePdAtPfKfolds,
%   prtScorePfAtPd, prtScorePfAtPdKfolds, prtScoreRoc

Results = kfolds(PrtClass,DS,nFolds);
[~,~,auc] = prtScoreRoc(Results.getObservations,DS.getTargets);