function [cost, pf, pd] = prtEvalMinCost(classifier,dataSet,costMatrix,nFolds)
% prtEvalMinCost   Returns the minimum cost of classification
%
%   cost = prtEvalMinCost(prtClassifier, prtDataSet, costMat) returns the
%   minimum cost of classification of dataset prtDataSet with classifier
%   prtClassifier according to the cost matrix costMat. prtDataSet must be
%   a labeled, prtDataSetStandard object. prtClassifier must be a prtClass
%   object. costMat must be a 2x2 matrix consisting of the costs. costMat
%   = [C00, C10; C01 C11], where Cij is the cost for deciding i when j is
%   the truth.
%
%   cost = prtEvalMinCost(prtClassifier, prtDataSet,costMat, nFolds)
%   returns the minimum cost of classification of dataset prtDataSet with
%   classifier prtClassifier according to the cost matrix costMat with
%   K-fold cross-validation. prtDataSet must be a labeled, binary
%   prtDataSetStandard object. prtClassifier must be a prtClass object.
%   nFolds is the number of folds in the K-fold cross-validation.
%
%   cost = prtEvalMinCost(prtClassifier, prtDataSet,costMat, xValInds) same
%   as above, but use crossValidation with specified indices instead of
%   random folds.
%
%   [cost, PF, PD] =  prtScoreMinCost(...) returns the probability of false
%   alarm PF and the probability of detection PD.
%
%   Example: 
%   dataSet = prtDataGenSpiral; 
%   classifier = prtClassDlrt;
%   cost = prtEvalMinCost(classifier, dataSet,[ 0 1; 1 0])
%
%   See Also: prtEvalAuc, prtEvalPfAtPd, prtEvalPdAtPf
%   prtEvalPercentCorrect







if nargin < 3 || isempty(costMatrix)
    error('prt:prtEvalMinCost:tooFewInputs','prtEvalMinCost requires at least 3 input arguments');
end
if nargin < 4 || isempty(nFolds)
    nFolds = 1;
end
results = prtUtilEvalParseAndRun(classifier,dataSet,nFolds);

[cost,pf,pd] = prtScoreCost(results,dataSet,costMatrix);
[cost,minCostInd] = min(cost);
pf = pf(minCostInd);
pd = pd(minCostInd);
