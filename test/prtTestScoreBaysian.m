function result = prtTestScoreBaysian
% This function tests a few of the prtScore functions such as:
% prtScorePercentCorrect

result = true;

try  % This should not error.
    TestDataSet = prtDataGenSpiral;       % Create some test and
    TrainingDataSet = prtDataGenSpiral;   % training data
    classifier = prtClassSvm;             % Create a classifier
    classifier = classifier.train(TrainingDataSet);    % Train
    classified = run(classifier, TestDataSet);
    %  Plot the ROC
    prtScoreRocBayesianBootstrap(classified.getX, TestDataSet.getY);
    close all;
    
catch
    result = false;
    disp('prtScoreRocBayesianBootstrap basic fail')
end

% Check that I can pass in and out arguments

try  % This should not error.
    TestDataSet = prtDataGenSpiral;       % Create some test and
    TrainingDataSet = prtDataGenSpiral;   % training data
    classifier = prtClassSvm;             % Create a classifier
    classifier = classifier.train(TrainingDataSet);    % Train
    classified = run(classifier, TestDataSet);
    
    [a,b,c,d] =  prtScoreRocBayesianBootstrap(classified.getX, TestDataSet.getY, 500,500,.1);
    
    
catch
    result = false;
    disp('prtScoreRocBayesianBootstrap basic outputs fail')
    
end

%% Error check, make sure alpha is between 0 and 1
error = true;
try
    [a,b,c,d] =  prtScoreRocBayesianBootstrap(classified.getX, TestDataSet.getY, 500,500,-.1);
    error = false;
    disp('prtScoreBayesianBootstrap alpha negative fail')
catch
    % no-op
end

result = result && error;