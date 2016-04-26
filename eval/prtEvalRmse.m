function rmse = prtEvalRmse(regressor,dataSet,nFolds)
% prtEvalRmse   Calculate the root mean squaure error of a regression operation
% 
%   rmse = prtEvalRmse(prtRegressor, prtDataSet) returns the root mean
%   squared error of the elements of prtDataSet when regressed by
%   prtRegressor. prtDataSet must be a labeled, prtDataSetStandard object.
%   prtRegressor must be a prtRegress object.
%
%   rmse = prtEvalRmse(prtRegressor, prtDataSet, NFOLDS)  returns the root
%   mean squared error of the elements of prtDataSet when regressed by
%   prtRegressor with K-fold cross-validation. prtDataSet must be a
%   labeled, prtDataSetStandard object. CLASSIFIER must be a prtClass
%   object. NFOLDS is the number of folds in the K-fold cross-validation.
%
%   rmse = prtEvalRmse(prtRegressor, prtDataSet, xValInds) same as above,
%   but use crossValidation with specified indices instead of random folds.
%
%
%   Example:
%   dataSet = prtDataGenNoisySinc;
%   regress  = prtRegressRvm;
%   rmse =  prtEvalRmse(regress, dataSet)
%
%   See Also: prtEvalPdAtPf, prtEvalPfAtPd, prtEvalAuc,
%   prtEvalMinCost








assert(nargin >= 2,'prt:prtEvalRmse:BadInputs','prtEvalPercentCorrect requires two input arguments');
assert(isa(regressor,'prtAction') && isa(dataSet,'prtDataSetBase'),'prt:prtEvalMse:BadInputs','prtEvalMse inputs must be sublcasses of prtClass and prtDataSetBase, but input one was a %s, and input 2 was a %s',class(regressor),class(dataSet));

if nargin < 3 || isempty(nFolds)
    nFolds = 1;
end
results = prtUtilEvalParseAndRun(regressor,dataSet,nFolds);

rmse =  prtScoreRmse( results.getX, dataSet.getY);

