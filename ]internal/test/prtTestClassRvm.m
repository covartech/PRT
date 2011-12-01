function result = prtTestClassRvm
result = true;

% BASELINE generation, uncomment to run to generate new baseline
% Run numIter times to get idea distribution of percentage
% Pick off the lowest % correct and use that as baseline
% numIter = 100;
% percentCorr = zeros(1,numIter);
% for i = 1:numIter
%     TestDataSet = prtDataGenUnimodal;
%     TrainingDataSet = prtDataGenUnimodal;
%
%     classifier = prtClassRvm;
%     classifier = classifier.train(TrainingDataSet);
%     classified = run(classifier, TestDataSet);
%     classes  = classified.getX > .5;
%     percentCorr(i) = prtScorePercentCorrect(classes,TestDataSet.getTargets);
% end
% min(percentCorr)


%% Classification correctness test.
baselinePercentCorr =  0.9375;

TestDataSet = prtDataGenUnimodal;
TrainingDataSet = prtDataGenUnimodal;

classifier = prtClassRvm;
%classifier.verboseStorage = false;
classifier = classifier.train(TrainingDataSet);
classified = run(classifier, TestDataSet);

classes  = classified.getX > .5;

percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

if(percentCorr < baselinePercentCorr)
    result = false;
    disp('prtTestClass RVM below baseline')
end


% make sure plotting succeeds
try
    classifier.plot();
    close;
catch
    result = false;
    disp('Rvm class plot fail')
    close
end


%% Check that cross-val and k-folds work

TestDataSet = prtDataGenUnimodal;
classifier = prtClassRvm;

% cross-val
keys = mod(1:400,2);
crossVal = classifier.crossValidate(TestDataSet,keys);
classes  = crossVal.getX > .5;
percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

if(percentCorr < baselinePercentCorr)
    result = false;
    disp('prtTestClass  RVM  cross-val below baseline')
end

% k-folds

crossVal = classifier.kfolds(TestDataSet,10);
classes  = crossVal.getX > .5;
percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

if(percentCorr < baselinePercentCorr)
    result = false;
    disp('prtTestClass RVM kfolds below baseline')
end



%check learning plot and learning text
try
    classifier.verbosePlot = true;
    classifier.verboseText = true;
    classifier.learningMaxIterations = 10;
    classifier = classifier.train(TestDataSet);
    classified = run(classifier, TestDataSet);
    close all;
catch ME
    disp(ME);
    disp('Rvm learning plot/text fail')
    result = false;
end

classifier.verbosePlot = false;
classifier.verboseText = false;
classifier.learningMaxIterations = 100;
% check that i can change the kernels
kernSet = prtKernelDirect & prtKernelRbf;
classifier.kernels = kernSet;
classifier = classifier.train(TrainingDataSet);
classified = run(classifier, TestDataSet);

classes  = classified.getX > .5;

percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

if(percentCorr < baselinePercentCorr)
    result = false;
    disp('prtTestClass RVM below second baseline for different kernels')
end


%% Object construction
% We want these to be non-errors
noerror = true;

try
    classifier = prtClassRvm('learningMaxIterations', 40);
catch
    noerror = false;
end
% %%
result = result & noerror;
