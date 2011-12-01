function result = prtTestClassRvmFigueiredo
result = true;

% BASELINE generation, uncomment to run to generate new baseline
% Run numIter times to get idea distribution of percentage
% Pick off the lowest % correct and use that as baseline
numIter = 100;
percentCorr = zeros(1,numIter);
% for i = 1:numIter
%     TestDataSet = prtDataGenUnimodal;
%     TrainingDataSet = prtDataGenUnimodal;
% 
%     classifier = prtClassRvmFigueiredo;
%     classifier = classifier.train(TrainingDataSet);
%     classified = run(classifier, TestDataSet);
%     classes  = classified.getX > .5;
%     percentCorr(i) = prtScorePercentCorrect(classes,TestDataSet.getTargets);
% end
% min(percentCorr)


%% Classification correctness test.
baselinePercentCorr =  0.95;

TestDataSet = prtDataGenUnimodal;
TrainingDataSet = prtDataGenUnimodal;

classifier = prtClassRvmFigueiredo;
%classifier.verboseStorage = false;
classifier = classifier.train(TrainingDataSet);
classified = run(classifier, TestDataSet);

classes  = classified.getX > .5;

percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

result = result & (percentCorr > baselinePercentCorr);

% make sure plotting succeeds
try
    classifier.plot();
    close;
catch
    result = false;
    disp('Rvm fig class plot fail')
    close
end


%% Check that cross-val and k-folds work

TestDataSet = prtDataGenUnimodal;
classifier = prtClassRvmFigueiredo;

% cross-val
keys = mod(1:400,2);
crossVal = classifier.crossValidate(TestDataSet,keys);
classes  = crossVal.getX > .5;
percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

result = result & (percentCorr > baselinePercentCorr);

% k-folds

crossVal = classifier.kfolds(TestDataSet,10);
classes  = crossVal.getX > .5;
percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

result = result & (percentCorr > baselinePercentCorr);

%check learning plot and learning text
try
    classifier.verbosePlot = 20;
    classifier.verboseText = true;
    classifier = classifier.train(TestDataSet);
    classified = run(classifier, TestDataSet);
    close all;
catch ME
    disp(ME);
    disp('Rvm fig learning plot/text fail')
    result = false;
end

% check that I can set all the params
try
    classifier.learningConvergedTolerance  = 6e-4;
    classifier.learningMaxIterations = 100;
    classifier.learningRelevantTolerance = 2e-6;
catch ME
    disp(ME)
    disp('RVM fig param set fail')
    result = false
end

%% Object construction
% We want these to be non-errors
noerror = true;

try
    classifier = prtClassRvmFigueiredo('learningMaxIterations', 40);
catch
    noerror = false;
end
% %%
result = result & noerror;
