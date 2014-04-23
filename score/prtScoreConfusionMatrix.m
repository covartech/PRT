function varargout = prtScoreConfusionMatrix(guess, truth, possibleTruthValues, classNames)
%[confMat,occurances] = prtScoreConfusionMatrix(guess,truth)
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
%    See also: prtScoreRoc, prtScoreRmse, prtScoreRocNfa,
%    prtScorePercentCorrect, prtScoreAuc

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


% guess = [0;0;1;2;3;]; truth = [0;1;1;4;3;];
% prtScoreConfusionMatrix(guess,truth)
% prtScoreConfusionMatrix(guess,truth,[0 1 2 3 4])
% prtScoreConfusionMatrix(guess,truth,[0 1 2 3 4],{'A','B','C','D','E'})
% prtScoreConfusionMatrix(prtDataSetClass(guess,guess,'classNames',{'0','1','2','3'}),prtDataSetClass(nan(size(truth,1),1),truth,'classNames',{'A','B','C','D'}))
% prtScoreConfusionMatrix(prtDataSetClass(guess,guess,'classNames',{'0','1','2','3'}),prtDataSetClass(nan(size(truth,1),1),truth,'classNames',{'A','B','C','D'}),0:4,{'aa','bb','cc','dd','ee'})


if (nargin == 1 || isempty(truth)) && isa(guess,'prtDataSetClass')
    truth = guess;
end

[guess, truth, allClassNames, uniqueTruthValues, guessClassNames, truthClassNames, uClassesGuess, uClassesTruth] = prtUtilScoreParseFirstTwoInputs(guess,truth); %#ok<ASGLU>

assert(size(guess,2)==1,'guess should be a prtDataSet with 1 feature or a vector');

% Parse 3rd and 4th inputs
%% These inputs are used to 
if nargin < 3 || isempty(possibleTruthValues)
    % Nothing do to keep from above
    %uClassesTruth = possiblGuessValues;
    %uClassesGuess = possiblGuessValues;
else
    % if you supplied possiblTruthValues we will make a square matrix with
    % these values. It is possible here that values in truth do not match those
    % in possibleGuessValues this will result in confusion matrices that do not
    % sum to 100% accross the rows.
    
    %uClassesTruth = intersect(possibleTruthValues,uClassesTruth);
    uClassesTruth = possibleTruthValues;
    uClassesGuess = possibleTruthValues;
end
if nargin < 4 || isempty(classNames)
    % Nothing to do  already have everything we need from above
    
    if nargin >= 3 && ~isempty(possibleTruthValues)
        % You supplied possibleTruthValues but not classNames
        % We need to generate appropriate classNames
        possibleTruthValues = possibleTruthValues(:);
        tempDs = prtDataSetClass(nan(size(possibleTruthValues,1),1),possibleTruthValues);
        classNames = tempDs.classNames;
        
        guessClassNames = classNames;
        truthClassNames = classNames;
    else
        % You didn't supply classNames or possibleTruthValues
        % everything is known from above
    end
else
    % You supplied classNames
    if nargin < 3 || isempty(possibleTruthValues)
        % You didn't supply possibleTruthValues
        % We will assume that you want the default joint truth values, but
        % we must check the dimensionality
        assert(length(uniqueTruthValues) == length(classNames),'prt:prtScoreConfusionMatrix:badInput','length of classNames does not match the number of unique values contained in both guess and truth');
        
        uClassesTruth = uniqueTruthValues;
        uClassesGuess = uniqueTruthValues;
        
        truthClassNames = classNames;
        guessClassNames = classNames;
    else
        % You supplied both must check the dimensionality
        assert(length(possibleTruthValues) == length(classNames),'prt:prtScoreConfusionMatrix:badInput','length of classNames must match the length of possibleTruthValues');
        
        uClassesTruth = possibleTruthValues;
        uClassesGuess = possibleTruthValues;
        
        truthClassNames = classNames;
        guessClassNames = classNames;
        
    end
end

if length(truth) ~= length(guess)
    error('prt:prtScoreConfusionMatrix:badInputs','guess and truth inputs must be the same length, or they must be prtDataSets with the same number of observations.')
end


nUClassesTruth = length(uClassesTruth);
nUClassesGuess = length(uClassesGuess);

confusionMat = zeros([nUClassesTruth,nUClassesGuess]);
occurances = zeros(nUClassesTruth,1);

for iTruthNum = 1:nUClassesTruth
    iTruth = uClassesTruth(iTruthNum);
    iTruthLocs = truth == iTruth;
    for jRespNum = 1:nUClassesGuess
        jResp = uClassesGuess(jRespNum);
        confusionMat(iTruthNum,jRespNum) = sum(guess(iTruthLocs) == jResp);
    end
    occurances(iTruthNum) = sum(iTruthLocs);
end

varargout = {};
if nargout 
    varargout = {confusionMat, occurances};
else
    %prtUtilPlotConfusionMatrix(bsxfun(@rdivide,confusionMat,occurances),guessClassNames,truthClassNames);
    prtUtilPlotConfusionMatrix(confusionMat,guessClassNames,truthClassNames);
    
    pc = prtScorePercentCorrect(guess,truth);
    title(sprintf('%.2f%% Correct',pc*100));

end
