function [cost,pf,pd] = prtScoreCost(ds,y,costMatrix)
% prtScoreCost  Return the cost vector
%
%    COST = prtScoreCost(DECSTATS,LABELS, COSTMAT) returns the cost vector
%    COST for the decision statistics DECSTATS and the corresponding labels
%    LABELS, according to the cost matrix COSTMAT. DECSTATS must be a Nx1
%    vector of decision statistics. LABELS must be a Nx1 vector of binary
%    class labels. COST must be a 2x2 matrix, where Cij is the cost of
%    deciding i when the truth is j.
%
%    [COST, PF, PD] = prtScoreRoc(DECSTATS,LABELS) returns the probability
%    of false alarm PF, the probability of detection PD at the
%    corresponding COST.
%
%    Example:     
%    TestDataSet = prtDataGenSpiral;       % Create some test and
%    TrainingDataSet = prtDataGenSpiral;   % training data
%    classifier = prtClassSvm;             % Create a classifier
%    classifier = classifier.train(TrainingDataSet);    % Train
%    classified = run(classifier, TestDataSet);     
%    %  Compute the cost vector
%    C = prtScoreCost(classified.getX, TestDataSet.getY, [1 .1; .1 1]);
%
%   See also prtScoreConfusionMatrix, prtScoreRmse,
%   prtScorePercentCorrect

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


[ds,y] = prtUtilScoreParseFirstTwoInputs(ds,y);
[pf,pd] = prtScoreRoc(ds,y);
cost = prtUtilPfPd2Cost(pf,pd,costMatrix);
