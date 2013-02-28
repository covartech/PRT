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



assert(nargin >= 2,'prt:prtEvalRmse:BadInputs','prtEvalPercentCorrect requires two input arguments');
assert(isa(regressor,'prtAction') && isa(dataSet,'prtDataSetBase'),'prt:prtEvalMse:BadInputs','prtEvalMse inputs must be sublcasses of prtClass and prtDataSetBase, but input one was a %s, and input 2 was a %s',class(regressor),class(dataSet));

if nargin < 3 || isempty(nFolds)
    nFolds = 1;
end
results = prtUtilEvalParseAndRun(regressor,dataSet,nFolds);

rmse =  prtScoreRmse( results.getX, dataSet.getY);

