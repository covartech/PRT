function result = prtTestClassTreeBaggingCap
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
%     classifier = prtClassTreeBaggingCap;
%     classifier = classifier.train(TrainingDataSet);
%     classified = run(classifier, TestDataSet);
%     classes  = classified.getX > .5;
%     percentCorr(i) = prtScorePercentCorrect(classes,TestDataSet.getTargets);
% end
% min(percentCorr)


%% Classification correctness test.
baselinePercentCorr =  0.9325;

TestDataSet = prtDataGenUnimodal;
TrainingDataSet = prtDataGenUnimodal;
%TrainingDataSet = .catFeatures(prtDataGenUnimodal,prtDataGenUnimodal);

nTrees = 100;

classifier = prtClassTreeBaggingCap('nTrees',nTrees); % 
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
    disp('TreeBaggingCap class plot fail')
    close
end


%% Check that cross-val and k-folds work

TestDataSet = prtDataGenUnimodal;
classifier = prtClassTreeBaggingCap('nTrees',nTrees);

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

% check that i can change cap classifier
% try
%     CAP = prtClassCap;
%     classifier.CapClassifier = {CAP};
%     classifier = classifier.train(TrainingDataSet);
%     classified = run(classifier, TestDataSet);
%     
% catch
%     result = false;
%     disp('error changing classifier TreeBaggingCap classifier')
% end
% 


%check that i can turn off bootstrapping
try
    % classifier.bootStrapDataAtNodes = false;
    classifier.bootStrapDataAtRoots = false;
    
    classifier = classifier.train(TestDataSet);
    classified = run(classifier, TestDataSet);
    
catch
    disp('TreeBaggingCap boostrapping fail')
    result = false;
end


%% Object construction
% We want these to be non-errors
noerror = true;

try
    classifier = prtClassTreeBaggingCap('nTrees', 40);
catch
    noerror = false;
end
% %%
result = result & noerror;
