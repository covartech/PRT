function auc = prtEvalAuc(classifier,dataSet,nFolds)
%prtEvalAuc   Score by the area under curve method
%
%   auc = prtEvalAuc(class,dataSet)
%   auc = prtEvalAuc(class,dataSet,nFolds)

if nargin < 3 || isempty(nFolds)
    nFolds = 1;
end
Results = classifier.kfolds(dataSet,nFolds);
[~,~,auc] = prtScoreRoc(Results.getObservations,dataSet.getTargets);