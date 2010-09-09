function [cost, pf, pd] = prtEvalMinCost(classifier,dataSet,costMatrix,nFolds)
% prtEvalMinCost   Returns the minimum cost of classification
%
%   COST = prtEvalMinCost(CLASSIFIER, DATASET,COSTMAT) returns the minimum
%   cost of classification of dataset DATASET with classifier CLASSIFIER
%   according to the cost matrix COSTMAT. DATASET must be a labeled,
%   prtDataSetStandard object. CLASSIFIER must be a prtClass object.
%   COSTMAT must be a 2x2 matrix consisting of the costs.
%   COSTMAT  = [C00, C10; C01 C11], where Cij is the cost for deciding i 
%   when j is the truth.
%
%   COST = prtScoreMinCost(CLASSIFIER, DATASET, NFOLDS)  returns the minimum
%   cost of classification of dataset DATASET with classifier CLASSIFIER
%   according to the cost matrix COSTMAT with K-fold cross-validation.
%   DATASET must be a labeled, binary prtDataSetStandard object. CLASSIFIER
%   must be a prtClass object. NFOLDS is the number of folds in the K-fold
%   cross-validation.
%
%   [COST, PF, PD] =  prtScoreMinCost(...) returns the probability of false
%   alarm PF and the probability of detection PD.
%
%   Example: 
%   dataSet = prtDataGenSpiral; 
%   classifier = prtClassDlrt;
%   cost = prtEvalMinCost(classifier, dataSet,[ 0 1; 1 0])
%
%   See Also: prtEvalAuc, prtEvalPfAtPd, prtEvalPfAtPf
%   prtEvalPercentCorrect

%cost = prtEvalMinCost(DS,PrtClassOpt,costMatrix,nFolds)

assert(nargin >= 2,'prt:prtEvalMinCost:BadInputs','prtEvalMinCost requires two input arguments');
assert(isa(classifier,'prtAction') && isa(dataSet,'prtDataSetBase'),'prt:prtEvalMinCost:BadInputs','prtEvalMinCost inputs must be sublcasses of prtClass and prtDataSetBase, but input one was a %s, and input 2 was a %s',class(classifier),class(dataSet));

if nargin < 4 || isempty(nFolds)
    nFolds = 1;
end

results = kfolds(classifier,dataSet,nFolds);
[cost,pf,pd] = prtScoreCost(results,dataSet,costMatrix);
[cost,minCostInd] = min(cost);
pf = pf(minCostInd);
pd = pd(minCostInd);