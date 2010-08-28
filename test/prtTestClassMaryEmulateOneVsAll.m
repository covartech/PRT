function result = prtTestClassMaryEmulateOneVsAll
result = true;

% BASELINE generation, uncomment to run to generate new baseline
% Run numIter times to get idea distribution of percentage
% Pick off the lowest % correct and use that as baseline
% numIter = 1000;
% percentCorr = zeros(1,numIter);
% for i = 1:numIter
%     TestDataSet = prtDataGenMary;
%     TrainingDataSet = prtDataGenMary;
%     
%     classifier = prtClassMaryEmulateOneVsAll;
%     classifier.Classifiers = prtClassGlrt;
%     classifier = classifier.train(TrainingDataSet);
%     classified = run(classifier, TestDataSet);
%     classes  = classified.getX;
%     percentCorr(i) = prtScorePercentCorrect(classes,TestDataSet.getTargets);
% end
% min(percentCorr)


%% Classification correctness test.
baselinePercentCorr = .8;

TestDataSet = prtDataGenMary;
TrainingDataSet = prtDataGenMary;


classifier = prtClassMaryEmulateOneVsAll;
classifier.Classifiers = prtClassGlrt;

classifier = classifier.train(TrainingDataSet);
classified = run(classifier, TestDataSet);

[~,classInds] = max(classified.getX(),[],2);
classes = TestDataSet.uniqueClasses(classInds);

percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

result = result & (percentCorr > baselinePercentCorr);
if (percentCorr < baselinePercentCorr)
    disp('prtClassMaryEmulateOneVsAll below baseline')
    result = false;
end


%% Check that cross-val and k-folds work

TestDataSet = prtDataGenMary;

classifier = prtClassMaryEmulateOneVsAll;
classifier.Classifiers = prtClassGlrt;


% cross-val
keys = mod(1:300,2);
crossVal = classifier.crossValidate(TestDataSet,keys);
[~,classInds] = max(crossVal.getX(),[],2);
classes = TestDataSet.uniqueClasses(classInds);
percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

if (percentCorr < baselinePercentCorr)
    disp('prtClassMaryEmulateOneVsAll cross-val below baseline')
    result = false;
end

% k-folds

crossVal = classifier.kfolds(TestDataSet,10);
[~,classInds] = max(crossVal.getX(),[],2);
classes = TestDataSet.uniqueClasses(classInds);

percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);
if (percentCorr < baselinePercentCorr)
    disp('prtClassMaryEmulateOneVsAll kfolds below baseline')
    result = false;
end



%% Error checks

error = true;  % We will want all these things to error



%% Object construction
% We want these to be non-errors
noerror = true;

try
    classifier = prtClassMaryEmulateOneVsAll('Classifiers', prtClassMap);
    classifier = classifier.train(TrainingDataSet);
    classified = run(classifier, TestDataSet);
    
catch
    noerror = false;
    disp('OVA prototypes param/val fail')
end

try
    TestDataSet = prtDataGenMary;
    TrainingDataSet = prtDataGenMary;
    
    
    classifier = prtClassMaryEmulateOneVsAll;
    classifier = classifier.train(TrainingDataSet);
    classifier.plot();
    close
catch
    noerror = false;
    disp('OVA plot fail')
    close
end
%%
result = result & error & noerror;
