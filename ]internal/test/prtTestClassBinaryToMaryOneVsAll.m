function result = prtTestClassBinaryToMaryOneVsAll

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
%     TestDataSet = prtDataGenMary;
%     TrainingDataSet = prtDataGenMary;
%     
%     classifier = prtClassBinaryToMaryOneVsAll;
%     classifier.baseClassifier = prtClassGlrt;
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


classifier = prtClassBinaryToMaryOneVsAll;
classifier.baseClassifier = prtClassGlrt;

classifier = classifier.train(TrainingDataSet);
classified = run(classifier, TestDataSet);

[twiddle,classInds] = max(classified.getX(),[],2);
classes = TestDataSet.uniqueClasses(classInds);

percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

result = result & (percentCorr > baselinePercentCorr);
if (percentCorr < baselinePercentCorr)
    disp('prtClassBinaryToMaryOneVsAll below baseline')
    result = false;
end


%% Check that cross-val and k-folds work

TestDataSet = prtDataGenMary;

classifier = prtClassBinaryToMaryOneVsAll;
classifier.baseClassifier = prtClassGlrt;


% cross-val
keys = mod(1:300,2);
crossVal = classifier.crossValidate(TestDataSet,keys);
[twiddle,classInds] = max(crossVal.getX(),[],2);
classes = TestDataSet.uniqueClasses(classInds);
percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

if (percentCorr < baselinePercentCorr)
    disp('prtClassBinaryToMaryOneVsAll cross-val below baseline')
    result = false;
end

% k-folds

crossVal = classifier.kfolds(TestDataSet,10);
[twiddle,classInds] = max(crossVal.getX(),[],2);
classes = TestDataSet.uniqueClasses(classInds);

percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);
if (percentCorr < baselinePercentCorr)
    disp('prtClassBinaryToMaryOneVsAll kfolds below baseline')
    result = false;
end



%% Error checks

error = true;  % We will want all these things to error



%% Object construction
% We want these to be non-errors
noerror = true;

try
    classifier = prtClassBinaryToMaryOneVsAll('baseClassifier', prtClassMap);
    classifier = classifier.train(TrainingDataSet);
    classified = run(classifier, TestDataSet);
    
catch
    noerror = false;
    disp('OVA prototypes param/val fail')
end

try
    TestDataSet = prtDataGenMary;
    TrainingDataSet = prtDataGenMary;
    
    
    classifier = prtClassBinaryToMaryOneVsAll;
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
