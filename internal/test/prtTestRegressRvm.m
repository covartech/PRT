function result = prtTestRegressRvm
result = true;


% % Create a baseline rmse
% numIter = 1000;
% rmseResult = zeros(1,numIter);
% for i = 1:numIter
%     dataSet = prtDataGenNoisySinc;
%     reg = prtRegressRvm;
%     reg = reg.train(dataSet);   
%     dataOut = reg.run(dataSet);
%     rmseResult(i) = prtScoreRmse(sinc(dataSet.getX), dataOut.getX);
% end
% rmseBase = max(rmseResult);
% %
rmseBase =  0.4;
% Check that basic operation works
dataSet = prtDataGenNoisySinc;           % Load a prtDataRegress
try
    reg = prtRegressRvm;             % Create a prtRegressRvm object
    reg = reg.train(dataSet);        % Train the prtRegressRvm object
    reg.plot();                      % Plot the result
    dataOut = reg.run(dataSet);
    close
catch
    result = false;
    disp('prtTestRegressRvn basic fail')
end

% Check that the non-default algo  works
dataSet = prtDataGenNoisySinc;           % Load a prtDataRegress
try
    reg = prtRegressRvmSequential;             % Create a prtRegressRvm object
    reg = reg.train(dataSet);        % Train the prtRegressRvm object
    reg.plot();                      % Plot the result
    dataOut = reg.run(dataSet);
    close
catch
    result = false;
    disp('prtTestRegressRvn sequential basic fail')
end

% Check vs the baseline
 rmse = prtScoreRmse(sinc(dataSet.getX), dataOut.getX);
 if rmse > rmseBase
     result = false;
     disp('prtTestRegressRvm rmse greater than baseline')
 end
 

% % Check param-val constuctor
% try
%     %reg = prtRegressRvm('algorithm','Sequential');
% catch
%     result = false;
%     disp('prtTestRegressRvm param-val constructor fail')
% end
%
% % check that plotting the training works
% dataSet = prtDataGenNoisySinc;           % Load a prtDataRegress
% try
%     reg = prtRegressRvm;             % Create a prtRegressRvm object
%     reg.LearningPlot = true;
%     reg = reg.train(dataSet);        % Train the prtRegressRvm object
%     reg.plot();                      % Plot the result
%     close
% catch
%     result = false;
%     disp('prtTestRegressRvn learing plot fail')
%     close all;
% end

% make sure k-folds works(kfolds will implicity test cross-val)
dataSet = prtDataGenNoisySinc;           % Load a prtDataRegress
try
    reg = prtRegressRvm;             % Create a prtRegressRvm object
    [dataOut, regOut] = reg.kfolds(dataSet,10);        % Train the prtRegressRvm object
    regOut(1).plot;                      % Plot the result
    close
catch
    result = false;
    disp('prtTestRegressRvn kfolds fail')
end

%% Some error checks
error = true;

% Check the algorithm is set right
reg = prtRegressRvm;
try
    reg.algorithm = 'sam';
    error = false;
    disp('prtRegressRvm algorithm set to invalid string')
catch
    %% no-op
end

result=  result && error;