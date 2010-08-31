function auc = prtEvalAuc(classifier,dataSet,nFolds)
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