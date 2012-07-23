function rmse = prtEvalRmse(regressor,dataSet,nFolds)
% PRTEVALRMSE   Calculate the root mean squaure error of a regression operation
% 
%   RMSE = prtEvalRmse(REGRESS, DATASET) returns the root mean squared error
%   of the elements of DATASET when regressed by REGRESS. DATASET must be a
%   labeled, prtDataSetStandard object. REGRESS must be a prtRegress
%   object.
%
%   RMSE = prtEvalRmse(REGRESS, DATASET, NFOLDS)  returns the root mean
%   squared error of the elements of DATASET when regressed by REGRESS with
%   K-fold cross-validation. DATASET must be a labeled, prtDataSetStandard
%   object. CLASSIFIER must be a prtClass object. NFOLDS is the number of
%   folds in the K-fold cross-validation.
%
%
%   Example:
%   dataSet = prtDataGenNoisySinc;
%   regress  = prtRegressRvm;
%   rmse =  prtEvalRmse(regress, dataSet)
%
%   See Also: prtEvalPdAtPf, prtEvalPfAtPd, prtEvalAuc,
%   prtEvalMinCost


% Copyright 2010, New Folder Consulting, L.L.C.

assert(nargin >= 2,'prt:prtEvalRmse:BadInputs','prtEvalPercentCorrect requires two input arguments');
assert(isa(regressor,'prtAction') && isa(dataSet,'prtDataSetBase'),'prt:prtEvalMse:BadInputs','prtEvalMse inputs must be sublcasses of prtClass and prtDataSetBase, but input one was a %s, and input 2 was a %s',class(regressor),class(dataSet));

if nargin < 3 || isempty(nFolds)
    nFolds = 1;
end
results = regressor.kfolds(dataSet,nFolds);

rmse =  prtScoreRmse( results.getX, dataSet.getY);

