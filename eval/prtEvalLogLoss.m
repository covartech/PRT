function logLoss = prtEvalLogLoss(classifier,dataSet,nFolds)
% prtEvalLogLoss    Calculate log-loss after applying classifier to dataSet
% 
%   logLoss = prtEvalLogLoss(prtClassifier, prtDataSet) returns the
%   log-Loss for prtDataSet when classified by prtClassifier. prtDataSet
%   must be a labeled, prtDataSetStandard object. prtClassifier must be a
%   prtClass object.
%
%   logLoss = prtEvalLogLoss(prtClassifier, prtDataSet, nFolds)  returns
%   the log-Loss of prtDataSet when classified by prtClassifier with K-fold
%   cross-validation. prtDataSet must be a labeled, prtDataSetStandard
%   object. prtClassifier must be a prtClass object. nFolds is the number
%   of folds in the K-fold cross-validation.
%
%   logLoss = prtEvalLogLoss(prtClassifier, prtDataSet, xValInds) same as
%   above, but use crossValidation with specified indices instead of random
%   folds.
%
%       Note: since a lower log-loss is better, if log-loss is used in
%       feature selection, for example, you should optimize over the *negative*
%       log-loss.
% 
%   See the help for prtScoreLogLoss for more information.
%
%   Example:
%   dataSet = prtDataGenSpiral;
%   classifier = prtClassDlrt;
%   ll = prtEvalLogLoss(classifier, dataSet)
%
%   See Also: prtScoreLogLoss, prtEvalPdAtPf, prtEvalPfAtPd, prtEvalAuc, 
%   prtEvalMinCost, prtEvalPercentCorrect

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

if nargin < 3 || isempty(nFolds)
    nFolds = 1;
end
results = prtUtilEvalParseAndRun(classifier,dataSet,nFolds);
logLoss = prtScoreLogLoss(results);
