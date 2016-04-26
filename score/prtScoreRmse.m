function rmse = prtScoreRmse(dataSet1, dataSet2)
% RMSE = prtScoreRmse(GUESS, TRUTH)
%
%   RMSE = prtScoreRmse(GUESS, TRUTH) returns the
%   root mean squared error between the guesses in GUESS as compared to the truth in TRUTH.
%   GUESS and TRUTH should both be Nx1 vectors, or both be prtDataSets.  If
%   they are prtDataSets, TRUTH.isLabeled must be true.
%
%   Example:
%   dataSet = prtDataGenNoisySinc;   % Load a prtDataRegress data set, a
%                                    % noisy Sinc function
%   reg = prtRegressRvm;             % Create a prtRegressRvm object
%   reg = reg.train(dataSet);        % Train the prtRegressRvm object
%   dataSetOut = reg.run(dataSet);   % Run the regressor on the data
%
%   truth = sinc(dataSet.getX);
%   guess = dataSetOut.getX;
%   prtScoreRmse(truth, guess)
%
%     
%   See also prtScoreConfusionMatrix, prtScoreRoc, prtScorePercentCorrect







if nargin < 2
    dataSet2 = dataSet1;
end 

[guesses,targets] = prtUtilScoreParseFirstTwoInputs(dataSet1,dataSet2);

if size(guesses,2) == 1
    rmse = sqrt(mean((guesses-targets).^2));
else %M-ary regression
    eSquared = (guesses-targets).^2;
    rmse = sqrt(mean(eSquared(:)));
end
