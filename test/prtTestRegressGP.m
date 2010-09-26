function result = prtTestRegressGP
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

rmseBase = .3574;
    
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