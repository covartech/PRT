function cost = prtEvalMinCost(classifier,dataSet,costMatrix,nFolds)
%cost = prtEvalMinCost(DS,PrtClassOpt,costMatrix,nFolds)

assert(nargin >= 2,'prt:prtEvalMinCost:BadInputs','prtEvalMinCost requires two input arguments');
assert(isa(classifier,'prtClass') && isa(dataSet,'prtDataSetBase'),'prt:prtEvalMinCost:BadInputs','prtEvalMinCost inputs must be sublcasses of prtClass and prtDataSetBase, but input one was a %s, and input 2 was a %s',class(classifier),class(dataSet));

if nargin < 4 || isempty(nFolds)
    nFolds = 1;
end

results = kfolds(classifier,dataSet,nFolds);

[pf,pd] = prtScoreRoc(results.getObservations,dataSet.getTargets);
cost = prtUtilPfPd2Cost(pf,pd,costMatrix);
cost = min(cost);