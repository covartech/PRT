function percentCorrect = prtScorePercentCorrect(dataSet1,dataSet2)
% prtScorePercentCorrect(dataSet1,dataSet2)
% prtScorePercentCorrect(x,y)
%
%   x or dataSet1 should contain a n x 1 vector of class guesses, that
%   hopefully match the data in dataSet2

[guesses,targets] = prtUtilScoreParseFirstTwoInputs(dataSet1,dataSet2);

if size(guesses,2) ~= 1 
    error('prt:prtScorePercentCorrect','Requires dataSet1 to be a n x 1 integer vector of class guesses');
else
    confusionMatrix = prtScoreConfusionMatrix(guesses,targets);
    percentCorrect = prtUtilConfusion2PercentCorrect(confusionMatrix);
end
  