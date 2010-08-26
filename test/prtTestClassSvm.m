function result = prtTestClassSvm
result = true;

% BASELINE generation, uncomment to run to generate new baseline
% Run numIter times to get idea distribution of percentage
% Pick off the lowest % correct and use that as baseline
% numIter = 100;
% percentCorr = zeros(1,numIter);
% for i = 1:numIter
%     TestDataSet = prtDataUniModal;
%     TrainingDataSet = prtDataUniModal;
% 
%     classifier = prtClassSvm;
%     classifier = classifier.train(TrainingDataSet);
%     classified = run(classifier, TestDataSet);
%     classes  = classified.getX > .5;
%     percentCorr(i) = prtScorePercentCorrect(classes,TestDataSet.getTargets);
% end
% min(percentCorr)
% 

%% Classification correctness test.
baselinePercentCorr =  0.9400;

TestDataSet = prtDataUniModal;
TrainingDataSet = prtDataUniModal;

classifier = prtClassSvm;
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
    disp('Svm class plot fail')
    close
end


%% Check that cross-val and k-folds work

TestDataSet = prtDataUniModal;
classifier = prtClassSvm;

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




%% Object construction
% We want these to be non-errors
noerror = true;

try
    classifier = prtClassSvm('kernels', {prtKernelRbf});
catch
    noerror = false;
end
% %%
result = result & noerror;
