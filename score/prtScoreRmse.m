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

if size(guesses,2) == 1
    rmse = sqrt(mean((guesses-targets).^2));
else %M-ary regression
    eSquared = (guesses-targets).^2;
    rmse = sqrt(mean(eSquared(:)));
end
