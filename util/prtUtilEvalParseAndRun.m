function Results = prtUtilEvalParseAndRun(classifier,dataSet,nFolds)
%Results = prtUtilEvalParseAndRun(classifier,dataSet,nFolds)
%  Called internally by prtEval* as a way to parse inputs and generate
%  results







assert(nargin >= 2,'prt:prtEval:BadInputs','prtEval* functions require at least two input arguments');
assert(isa(classifier,'prtAction') && isa(dataSet,'prtDataSetBase'),'prt:prtEvalAuc:BadInputs','prtEvalAuc inputs must be sublcasses of prtClass and prtDataSetBase, but input one was a %s, and input 2 was a %s',class(classifier),class(dataSet));

if isscalar(nFolds)
    Results = classifier.kfolds(dataSet,nFolds);
else
    Results = classifier.crossValidate(dataSet,nFolds);
end
