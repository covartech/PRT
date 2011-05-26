function varargout = prtScoreConfusionMatrix(guess,truth,nClasses,labelsIn)
%[confMat,occurances,labels] = prtScoreConfusionMatrix(guess,truth,nClasses)
% prtScoreConfusionMatrix Plot or return the confusion matrix
%
%   CONFMAT = prtScoreConfusionMatrix(GUESS, TRUTH) returns the confusion matrix that
%   results from comparing  GUESS as compared to the truth in TRUTH.
%   GUESS and TRUTH should both be Nx1 vectors. The elements of both TRUTH
%   and GUESS should be binary or interger class labels.
%
%   prtScoreConfustionMatrix(GUESS,TRUTH) called without any output
%   arguments plots the confusion matrix.
%
%    Example:     
%    TestDataSet = prtDataGenMary;        % Create some test and
%    TrainingDataSet = prtDataGenMary;   % training data
%    classifier = prtClassMap;             % Create a classifier
%    classifier.internalDecider = prtDecisionMap;
%    classifier = classifier.train(TrainingDataSet);    % Train
%    classified = run(classifier, TestDataSet);     
%    %  Display the confusion matrix
%    prtScoreConfusionMatrix(classified, TestDataSet)
%
%    See also: prtScoreoc, prtScoreRmse, prtScoreRocNfa,
%    prtScorePercentCorrect, prtScoreAuc

if (nargin == 1 || isempty(truth)) && isa(guess,'prtDataSetClass')
    truth = guess;
end

[guess,truth,labels] = prtUtilScoreParseFirstTwoInputs(guess,truth);
if nargin > 3
    labels = labelsIn;
end

guess = guess(:);
if nargin < 3
    nClasses = length(unique(cat(1,truth(:),guess(:))));
end

if length(truth) ~= length(guess)
    error('Truth and response inputs must be the same length')
end

confusionMat = zeros(nClasses);
occurances = zeros(nClasses);
classes = sort(unique(cat(1,truth(:),guess(:))));

for iTruthNum = 1:length(classes)
    iTruth = classes(iTruthNum);
    iTruthLocs = truth == iTruth;
    for jRespNum = 1:length(classes)
        jResp = classes(jRespNum);
        confusionMat(iTruthNum,jRespNum) = sum(guess(iTruthLocs) == jResp);
    end
    occurances(iTruthNum,:) = repmat(sum(iTruthLocs),nClasses,1);
end

varargout = {};
if nargout 
    varargout = {confusionMat, occurances, labels};
else
    prtUtilPlotConfusionMatrix(confusionMat./occurances,labels);
end