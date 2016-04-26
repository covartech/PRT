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
