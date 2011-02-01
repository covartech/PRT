function result = prtTestClassLogisticDiscriminant
result = true;

% BASELINE generation, uncomment to run to generate new baseline
% Run numIter times to get idea distribution of percentage
% Pick off the lowest % correct and use that as baseline
% numIter = 1000;
% percentCorr = zeros(1,numIter);
% for i = 1:numIter
%     TestDataSet = prtDataGenUnimodal;
%     TrainingDataSet = prtDataGenUnimodal;
% 
%     classifier = prtClassLogisticDiscriminant;
%     classifier = classifier.train(TrainingDataSet);
%     classified = run(classifier, TestDataSet);
%     classes  = classified.getX > .5;
%     percentCorr(i) = prtScorePercentCorrect(classes,TestDataSet.getTargets);
% end
% min(percentCorr)


%% Classification correctness test.
baselinePercentCorr = .9350;

TestDataSet = prtDataGenUnimodal;
TrainingDataSet = prtDataGenUnimodal;

classifier = prtClassLogisticDiscriminant;
classifier = classifier.train(TrainingDataSet);
classified = run(classifier, TestDataSet);

classes  = classified.getX > .5;

percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

if (percentCorr < baselinePercentCorr)
    disp('prtClassLogisticDiscriminant below baseline')
    result = false;
end


%% Check that cross-val and k-folds work

TestDataSet = prtDataGenUnimodal;
classifier = prtClassLogisticDiscriminant;

% cross-val
keys = mod(1:400,2);
crossVal = classifier.crossValidate(TestDataSet,keys);
classes  = crossVal.getX > .5;
percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

if (percentCorr < baselinePercentCorr)
    disp('prtClassLogisticDiscriminant cross-val below baseline')
    result = false;
end

% k-folds

crossVal = classifier.kfolds(TestDataSet,10);
classes  = crossVal.getX > .5;
percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);
if (percentCorr < baselinePercentCorr)
    disp('prtClassLogisticDiscriminant kfolds below baseline')
    result = false;
end

%% Error checks

error = true;  % We will want all these things to error

classifier = prtClassLogisticDiscriminant;

try
    classifier.rvH0 = 1;
    error = false;  % Set it to false if the preceding operation succeeded
    disp('Set rvH0 to non prt Rv')
catch
    % do nothing
    % We can potentially catch and check the error string here
    % For now, just be happy it is erroring out.
end


% Error check
try 
    classifier = prtClassLogisticDiscriminant;
    classifier.wInitTechnique = 'manual';
    classifier.manualInitialW = [1 2 3];
    classifier = classifier.train(TrainingDataSet);
    classified = run(classifier, TestDataSet);
     disp('LogisticDiscriminant set manual weights incorrectly')
     error = false;
catch
     % No-op
   
end

%% Object construction
% We want these to be non-errors
noerror = true;

try
    classifier = prtClassLogisticDiscriminant('handleNonPosDefR', 'regularize','maxIter', 20);
catch
    noerror = false;
    disp('LogisticDiscriminant param/val constructor fail');
end

try 
    classifier = prtClassLogisticDiscriminant;
    classifier.wInitTechnique = 'manual';
    classifier.manualInitialW = [1 2 3]';
    classifier = classifier.train(TrainingDataSet);
    classified = run(classifier, TestDataSet);
catch
    noerror = false;
    disp('LogisticDiscriminant set manual weights fail')
end



try 
    classifier = prtClassLogisticDiscriminant;
    classifier.wInitTechnique = 'randn';
    classifier = classifier.train(TrainingDataSet);
    classified = run(classifier, TestDataSet);
catch
    noerror = false;
    disp('LogisticDiscriminant set randn weights fail')
end


try 
    classifier = prtClassLogisticDiscriminant;
    classifier.irlsStepSize = 'hessian';
    classifier = classifier.train(TrainingDataSet);
    classified = run(classifier, TestDataSet);
catch
    noerror = false;
    disp('LogisticDiscriminant hessian stepsize fail')
end


try 
    classifier = prtClassLogisticDiscriminant;
    classifier.handleNonPosDefR = 'regularize';
    classifier = classifier.train(TrainingDataSet);
    classified = run(classifier, TestDataSet);
catch
    noerror = false;
    disp('LogisticDiscriminant regularize R fail')
end

%% 
result = result & error & noerror;
