function result = prtTestClassKnn

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.
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
%% Check the optimize function

ds = prtDataGenBimodal;  % Load a data set
knn = prtClassKnn;       % Create a classifier
kVec = 3:5:50;          % Create a vector of parameters to
% optimze over

% Optimize over the range of k values, using the area under
% the receiver operating curve as the evaluation metric.
% Validation is performed by a k-folds cross validation with
% 10 folds as specified by the call to prtEvalAuc.

try
[knnOptimize, percentCorrects] = knn.optimize(ds,@(class,ds)prtEvalAuc(class,ds,10), 'k',kVec);
catch me
    disp(me);
    disp('knn optimize fail');
    result= false;
end
% the optmized knn should have way more than 10 k's
if knnOptimize.k < 10
    disp('knn Optimize wrong k value')
    result = false
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
