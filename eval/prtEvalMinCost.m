function cost = prtEvalMinCost(classifier,dataSet,costMatrix,nFolds)
%cost = prtEvalMinCost(DS,PrtClassOpt,costMatrix,nFolds)

if nargin < 4 || isempty(nFolds)
    nFolds = 1;
end

results = kfolds(classifier,dataSet,nFolds);

[pf,pd] = prtScoreRoc(results.getObservations,dataSet.getTargets);
cost = prtUtilPfPd2Cost(pf,pd,costMatrix);
cost = min(cost);