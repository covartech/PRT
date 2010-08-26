function auc = prtScoreAuc(DS,PrtClassObj)
%prtScoreAuc   Score by the area under curve method
%
%   AUC = prtScoreAuc(DS,PRTCLASSOBJ) returns the area under the receiver
%   operating curve. DS must be a labeled, binary prtDataSetStandard
%   object. PRTCLASSOBJ must be a prtClass object.
%
%   Example:
%   dataSet = prtDataGenSpiral;
%   classifier = prtClassDlrt;
%   prtScoreAuc(dataSet,classifier)
%
%   See Also: prtScoreAucKfolds, prtScorePdAtPf, prtScorePdAtPfKfolds,
%   prtScorePfAtPd, prtScorePfAtPdKfolds, prtScoreRoc
Results = run(PrtClassObj.train(DS),DS);
[~,~,auc] = prtScoreRoc(Results.getObservations,DS.getTargets);