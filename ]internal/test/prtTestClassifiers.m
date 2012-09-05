function result = prtTestClassifiers

result = true;

% Get a list of the classification objects
files = what([prtRoot, '/class']);  % get a list of files
files = files.m;

% load the baseline
load baselineClassification

% instantiate function handles for the data generation and evaluation
% metrics
dataGenMet = @prtDataGenUnimodal;
evalMet = @(x,y)prtScorePercentCorrect(x,y);

% run all tests
result = prtTestRunCrossVal(files, baselineCell, dataGenMet, evalMet);