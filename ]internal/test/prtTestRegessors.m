function result = prtTestRegessors


% Get a list of the classification objects
files = what([prtRoot, '/regress']);  % get a list of files
files = files.m;

% load the baseline
load baselineRegress

% instantiate function handles for the data generation and evaluation
% metrics
dataGenMet = @prtDataGenNoisySinc;
evalMet = @(x,y)prtScoreRmse(x,y);

% run all tests
result = prtTestRunCrossVal(files, baselineCell,dataGenMet, evalMet);