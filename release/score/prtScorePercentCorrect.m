function percentCorrect = prtScorePercentCorrect(dataSet1,dataSet2)
% PERCENTCORRECT = prtScorePercentCorrect(GUESS, TRUTH)
%
%   PERCENTCORRECT = prtScorePercentCorrect(GUESS, TRUTH) returns the
%   percent of correct guesses in GUESS as compared to the truth in TRUTH.
%   GUESS and TRUTH should both be Nx1 vectors. The elements of both
%   TRUTH and GUESS should be binary or interger class labels.
%
%   Example:
%   TestDataSet = prtDataGenUniModal;       % Create some test and
%   TrainingDataSet = prtDataGenUniModal;   % training data
%   classifier = prtClassMap;               % Create a classifier
%   classifier = classifier.train(TrainingDataSet);    % Train
%   classified = run(classifier, TestDataSet);         % Test
%   classes  = classified.getX > .5;
%   percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets)
%
%   See also prtScoreConfusionMatrix, prtScoreRoc, prtScoreRmse

if nargin < 2
    dataSet2 = dataSet1;
end 

[guesses,targets] = prtUtilScoreParseFirstTwoInputs(dataSet1,dataSet2);

if size(guesses,2) ~= 1 
    error('prt:prtScorePercentCorrect','GUESS must be a N x 1 integer vector of class guesses');
else
    confusionMatrix = prtScoreConfusionMatrix(guesses,targets);
    percentCorrect = prtUtilConfusion2PercentCorrect(confusionMatrix);
end
  