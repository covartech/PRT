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

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


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
