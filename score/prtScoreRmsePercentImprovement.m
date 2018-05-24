function [rmseImprovement, rmseRaw, rmsePred] = prtScoreRmsePercentImprovement(dataSet1, dataSet2)
% [rmseImprovement, rmseRaw, rmsePred] = prtScoreRmsePercentImprovement(dataSet1)
%   Calculate the percent improvement in RMSE for
%       dataSet1.X - dataSet1.Y
%   vs.
%       mean(dataSet1.Y) - dataSet1.Y
%
%   



if nargin < 2
    dataSet2 = dataSet1;
end 

[guesses,targets] = prtUtilScoreParseFirstTwoInputs(dataSet1,dataSet2);

if size(guesses,2) == 1
    rmsePred = sqrt(mean((guesses-targets).^2));
elseif size(guesses,2) == size(targets,2)
    % M-ary regression
    eSquared = (guesses-targets).^2;
    rmsePred = sqrt(mean(eSquared(:)));
else
    eSquared = (guesses-targets).^2;
    rmsePred = sqrt(mean(eSquared));
end

rawESquared = (mean(targets)-targets).^2;
rmseRaw = sqrt(mean(rawESquared));
% 100 - 90 / 100 ==> 10% improvement
rmseImprovement = ((rmseRaw - rmsePred)./rmseRaw)*100;