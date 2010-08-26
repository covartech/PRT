function result = prtTestRegressLslr
result = true;


% % Create a baseline rmse
% numIter = 1000;
% rmseResult = zeros(1,numIter);
% for i = 1:numIter
%     dataSet = prtDataGenSinc;
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
dataSet = prtDataGenSinc;           % Load a prtDataRegress
try
    reg = prtRegressLslr;             % Create a prtRegressLslr object
    [dataOut, regOut] = reg.kfolds(dataSet,10);        % Train the prtRegressLslr object
    regOut(1).plot;                      % Plot the result
    close
catch
    result = false;
    disp('prtTestRegressRvn kfolds fail')
end
