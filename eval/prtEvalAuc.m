function auc = prtEvalAuc(classifier,dataSet,nFolds)
% prtEvalAuc   Returns the area under the receiver operating curve.
%
%   auc = prtEvalAuc(prtClassifier, prtDataSet) returns the area under the
%   receiver operating curve. prtDataSet must be a labeled, binary
%   prtDataSetStandard object. prtClassifier must be a prtClass object.
%
%   auc = prtEvalAuc(prtClassifier, prtDataSet, nFolds) returns the area
%   under the receiver operating curve with K-fold cross-validation.
%   prtDataSet must be a labeled, binary prtDataSetStandard object.
%   prtClassifier must be a prtClass object. nFolds is the number of folds
%   in the K-fold cross-validation.
%
%   auc = prtEvalAuc(prtClassifier, prtDataSet, xValInds) same as above,
%   but use crossValidation with specified indices instead of random folds.
%
%   Example:
%   dataSet = prtDataGenSpiral;
%   classifier = prtClassDlrt;
%   auc = prtEvalAuc(classifier, dataSet)
%
%   See Also: prtEvalPdAtPf, prtEvalPfAtPd, prtEvalPercentCorrect,
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


if nargin < 3 || isempty(nFolds)
    nFolds = 1;
end
Results = prtUtilEvalParseAndRun(classifier,dataSet,nFolds);
auc = prtScoreAuc(Results.getObservations,dataSet.getTargets);
