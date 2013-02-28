function [percentCorrect,correctLogical] = prtScorePercentCorrect(dataSet1,dataSet2)
% PERCENTCORRECT = prtScorePercentCorrect(GUESS, TRUTH)
%
%   PERCENTCORRECT = prtScorePercentCorrect(GUESS, TRUTH) returns the
%   percent of correct guesses in GUESS as compared to the truth in TRUTH.
%   GUESS and TRUTH should both be Nx1 vectors. The elements of both
%   TRUTH and GUESS should be binary or interger class labels.
%
%   Example:
%   TestDataSet = prtDataGenUnimodal;       % Create some test and
%   TrainingDataSet = prtDataGenUnimodal;   % training data
%   classifier = prtClassMap;               % Create a classifier
%   % Use minimum probablity of error rule
%   classifier.internalDecider = prtDecisionBinaryMinPe;
%   classifier = classifier.train(TrainingDataSet);    % Train
%   classified = run(classifier, TestDataSet);         % Test
%   percentCorr = prtScorePercentCorrect(classified,TestDataSet)
%
%   See also prtScoreConfusionMatrix, prtScoreRoc, prtScoreRmse

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


if nargin < 2
    dataSet2 = dataSet1;
end 

[guesses,targets] = prtUtilScoreParseFirstTwoInputs(dataSet1,dataSet2);

if size(guesses,2) ~= 1 
    error('prt:prtScorePercentCorrect','GUESS must be a N x 1 integer vector of class guesses');
else
    percentCorrect = mean(guesses == targets);
    if nargout > 1
        correctLogical = guesses == targets;
    end
end
