function result = prtTestClassKnn
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
%     classifier = prtClassKnn;
%     classifier = classifier.train(TrainingDataSet);
%     classified = run(classifier, TestDataSet);
%     classes  = classified.getX > .5;
%     percentCorr(i) = prtScorePercentCorrect(classes,TestDataSet.getTargets);
% end
% min(percentCorr)


%% Classification correctness test.
baselinePercentCorr =  0.8975;

TestDataSet = prtDataGenUnimodal;
TrainingDataSet = prtDataGenUnimodal;

classifier = prtClassKnn;
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
    disp('knn class plot fail')
    close
end


%% Check that cross-val and k-folds work

TestDataSet = prtDataGenUnimodal;
classifier = prtClassKnn;

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

% check that i can set a different distance function
try
classifier.distanceFunction = @(x1,x2)prtDistanceSquare(x1,x2);

classifier = classifier.train(TrainingDataSet);
classified = run(classifier, TestDataSet);
catch
    result = false;
    disp('error changing distance function Knn classifier')
end

% make sure i can set k
try
    classifier.k = 4;
catch
    disp('error changing k for Knn classifier')
    result = false;
end
%% Error checks

error = true;  % We will want all these things to error

classifier = prtClassKnn;

try
    classifier.twoClassParadigm = 'sam';
    error = false;  % Set it to false if the preceding operation succeeded
    disp('knn set two class paradigm')
catch
    % do nothing
    % We can potentially catch and check the error string here
    % For now, just be happy it is erroring out.
end


%% Object construction
% We want these to be non-errors
noerror = true;

try
    classifier = prtClassKnn('k', 4);
catch
    noerror = false;
end
% %% 
 result = result & noerror & error;
