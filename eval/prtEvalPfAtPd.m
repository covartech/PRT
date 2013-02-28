function pf = prtEvalPfAtPd(classifier,dataSet,pdDesired,nFolds)
% prtEvalPfAtPd   Returns the probability of false alarm at a desired
% probability of detection on the receiver operating curve.
%
%   pf = prtEvalPfAtPd(prtClassifier, prtDataSet,PD) returns the probabilty
%   of false alarm pf.  prtDataSet must be a labeled, binary
%   prtDataSetStandard object. prtClassifier must be a prtClass object. PD
%   is the desired probability of detection and must be between 0 and 1.
%
%   pf = prtEvalPfAtPd(prtClassifier, prtDataSet,PD, nFolds) returns the
%   probabilty of false alarm pf on the receiver operating curve with
%   K-fold cross-validation.  prtDataSet must be a labeled, binary
%   prtDataSetStandard object. prtClassifier must be a prtClass object. PD
%   is the desired probability of detection and must be between 0 and 1.
%   nFolds is the number of folds in the K-fold cross-validation.
%
%   pf = prtEvalPfAtPd(prtClassifier, prtDataSet, PD, xValInds) same as
%   above, but use crossValidation with specified indices instead of random
%   folds.
%
%   Example:
%   dataSet = prtDataGenSpiral;
%   classifier = prtClassDlrt;
%   pf =  prtEvalPfAtPd(classifier, dataSet,.9)
%
%   See Also: prtEvalAuc, prtEvalPfAtPd, prtEvalPercentCorrect,
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


assert(nargin >= 2,'prt:prtEvalPfAtPd:BadInputs','prtEvalPfAtPd requires two input arguments');
assert(isa(classifier,'prtAction') && isa(dataSet,'prtDataSetBase'),'prt:prtEvalPfAtPd:BadInputs','prtEvalPfAtPd inputs must be sublcasses of prtClass and prtDataSetBase, but input one was a %s, and input 2 was a %s',class(classifier),class(dataSet));

if nargin < 4 || isempty(nFolds)
    nFolds = 1;
end
results = prtUtilEvalParseAndRun(classifier,dataSet,nFolds);

[pf,pd] = prtScoreRoc(results.getObservations,dataSet.getTargets);
[pd,sortInd] = sort(pd(:),'ascend');
pf = pf(sortInd);

ind = find(pd >= pdDesired);
if ~isempty(ind)
    pf = pf(ind(1));
else
    pf = nan;
end
