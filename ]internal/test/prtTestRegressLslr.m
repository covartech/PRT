function result = prtTestRegressLslr

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
result = true;



% % Create a baseline rmse
% numIter = 1000;
% rmseResult = zeros(1,numIter);
% for i = 1:numIter
%     dataSet = prtDataGenNoisySinc;
%     x = [1:.5:10]';                % Create a linear, noisy data set.
%     y = 2*x + 3 + randn(size(x));
%     dataSet = prtDataSetRegress;  % Create a prtDataSetRegress object
%     dataSet= dataSet.setX(x);
%     dataSet = dataSet.setY(y);
%     reg = prtRegressLslr;            % Create a prtRegressRvm object
%     reg = reg.train(dataSet);        % Train the prtRegressRvm object
%     dataOut = reg.run(dataSet);
%     rmseResult(i) = prtScoreRmse(2*dataSet.getX + 3, dataOut.getX);
% end
% rmseBase = max(rmseResult);
% % %
rmseBase = 0.8568;
% Check that basic operation works

x = [1:.5:10]';                % Create a linear, noisy data set.
y = 2*x + 3 + randn(size(x));
dataSet = prtDataSetRegress;  % Create a prtDataSetRegress object
dataSet= dataSet.setX(x);
dataSet = dataSet.setY(y);
try
    reg = prtRegressLslr;             % Create a prtRegressLslr object
    reg = reg.train(dataSet);        % Train the prtRegressLslr object
    reg.plot();                      % Plot the result
    dataOut = reg.run(dataSet);
    close
catch
    result = false;
    disp('prtTestRegressRvn basic fail')
end

% Check vs the baseline
rmse = prtScoreRmse(2*dataSet.getX + 3, dataOut.getX);
if rmse > rmseBase
    result = false;
    disp('prtTestRegressLslr rmse greater than baseline')
end


% Check param-val constuctor
try
    reg = prtRegressLslr('beta',2);
    disp('prtTestRegressLslr param-val constructor fail')
    result = false;
catch
    % no-op
end
%
% make sure k-folds works(kfolds will implicity test cross-val)
dataSet = prtDataGenNoisySinc;           % Load a prtDataRegress
try
    reg = prtRegressLslr;             % Create a prtRegressLslr object
    [dataOut, regOut] = reg.kfolds(dataSet,10);        % Train the prtRegressLslr object
    regOut(1).plot;                      % Plot the result
    close
catch
    result = false;
    disp('prtTestRegressRvn kfolds fail')
end
