function result = prtTestRegressGP

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
%     reg = prtRegressGP;
%     reg = reg.train(dataSet);   
%     dataOut = reg.run(dataSet);
%     rmseResult(i) = prtScoreRmse(sinc(dataSet.getX), dataOut.getX);
% end
% rmseBase = max(rmseResult);
% %

% rmseBase = .3574; % This is a bit restrictive and we can sometimes fail
% even though we didn't - KDM
rmseBase = .4;

% Check that basic operation works
dataSet = prtDataGenNoisySinc;           % Load a prtDataRegress
try
    reg = prtRegressGP;             % Create a prtRegressGP object
    reg = reg.train(dataSet);        % Train the prtRegressGP object
    reg.plot();                      % Plot the result
    dataOut = reg.run(dataSet);
    close
catch
    result = false;
    disp('prtTestRegressGp basic fail')
end


% Check vs the baseline
 rmse = prtScoreRmse(sinc(dataSet.getX), dataOut.getX);
 if rmse > rmseBase
     result = false;
     disp('prtTestRegressGp rmse greater than baseline')
 end
 
 % Check param-val constuctor
try
    reg = prtRegressGP('noiseVariance',.2);
catch
    result = false;
    disp('prtTestRegressGP param-val constructor fail')
end


% make sure k-folds works(kfolds will implicity test cross-val)
dataSet = prtDataGenNoisySinc;           % Load a prtDataRegress
try
    reg = prtRegressGP;             % Create a prtRegressGP object
    [dataOut, regOut] = reg.kfolds(dataSet,10);        % Train the prtRegressGP object
    regOut(1).plot;                      % Plot the result
    close
catch
    result = false;
    disp('prtTestRegressGp kfolds fail')
end

%% Some error checks
error = true;

% Check the algorithm is set right
reg = prtRegressGP;
try
    reg.covarianceFunction = 'sam';
    error = false;
    disp('prtRegressGP covar invalid')
catch
    %% no-op
end

result=  result && error;
