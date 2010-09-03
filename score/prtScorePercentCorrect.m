function percentCorrect = prtScorePercentCorrect(dataSet1,dataSet2)
% PERCENTCORRECT = prtScorePercentCorrect(GUESS, TRUTH)
%
%   PERCENTCORRECT = prtSCOREPERCENTCORRECT(GUESS, TRUTH) returns the
%   percent of correct guesses in GUESS as compared to the truth in TRUTH.
%   GUESS and TRUTH should both be Nx1 vectors. The elements of both
%   TRUTH and GUESS should be binary or interger class labels.
%
%   Example:
%   TestDataSet = prtDataGenUniModal;       % Create some test and
%   TrainingDataSet = prtDataGenUniModal;   % training data
%   classifier = prtClassMap;           % Create a classifier
%   classifier = classifier.train(TrainingDataSet);    % Train
%   classified = run(classifier, TestDataSet);         % Test
%   classes  = classified.getX > .5;
%   percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets)
%
%   See also prtScoreAuc, prtScoreConfusionMatrix, prtScoreRoc,
%   prtScoreRocBayesianBootstrap, prtScoreRocBayesianBootstrapNfa
[guesses,targets] = prtUtilScoreParseFirstTwoInputs(dataSet1,dataSet2);

if size(guesses,2) ~= 1 
    error('prt:prtScorePercentCorrect','Requires dataSet1 to be a n x 1 integer vector of class guesses');
else
    confusionMatrix = prtScoreConfusionMatrix(guesses,targets);
    confusionMatrix
    percentCorrect = prtUtilConfusion2PercentCorrect(confusionMatrix);
end
  