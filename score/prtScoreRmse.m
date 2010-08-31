function rmse = prtScoreRmse(dataSet1,dataSet2)
% prtScoreRmse(dataSet1,dataSet2)
% prtScoreRmse(x,y)
%
%   x or dataSet1 should contain a n x 1 vector of values, that
%   hopefully match the data in dataSet2

[guesses,targets] = prtUtilScoreParseFirstTwoInputs(dataSet1,dataSet2);

if size(guesses,2) == 1
    rmse = sqrt(mean((guesses-targets).^2));
else %M-ary regression
    eSquared = (guesses-targets).^2;
    rmse = sqrt(mean(eSquared(:)));
end