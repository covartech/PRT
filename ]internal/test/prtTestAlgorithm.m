function result = prtTestAlgorithm

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


% test that we can instantiate a prtAlgorithm
try
    alg = prtAlgorithm(prtClassMap);
catch
    result = false;
    disp('prtAlgorithm constructor fail');
end

%% check that simple algorithm operation(one classifier) is equivalent to
% same function call of a classifier.
dataSetTest = prtDataGenUnimodal;
dataSetTrain = prtDataGenUnimodal;

% Create a classifier
class = prtClassMap;
class = class.train(dataSetTrain);
resultClass = class.run(dataSetTest);

% now do the same thing with a prtAlgorithm
alg = alg.train(dataSetTrain);
resultAlg = alg.run(dataSetTest);

if(~prtUtilApproxEqual(resultAlg.getX, resultClass.getX, eps*2))
    disp('prtAlgorithm basic classification not equal to prtClass result')
    result = false;
end


%% now try 2 stage classifier. Feature reduction followed by classification
featSel = prtFeatSelStatic;
featSel.selectedFeatures = 1;

featSel = featSel.train(dataSetTrain); 

dataSetSelTest = featSel.run(dataSetTest);
dataSetSelTrain = featSel.run(dataSetTrain);

% Create a classifier
class = prtClassMap;
class = class.train(dataSetSelTrain);
resultClass = class.run(dataSetSelTest);

% now do the same thing with a prtAlgorithm
alg = featSel + prtClassMap;

alg = alg.train(dataSetTrain);
resultAlg = alg.run(dataSetTest);

if(~prtUtilApproxEqual(resultAlg.getX, resultClass.getX, eps*2))
    result = false;
    disp('2 stage prtAlgorithm classification fail')
end

%% test a pre-processor, 2 paralell classifiers, followed by a 3rd
% classifier, oh my.

preProc = prtPreProcZmuv;

preProc = preProc.train(dataSetTrain);
dataSetTrainPre = preProc.run(dataSetTrain);
dataSetTestPre = preProc.run(dataSetTest);

% the two paralell classifiers
class1 = prtClassMap;
class2 = prtClassGlrt;

% Train both of them
class1 = class1.train(dataSetTrainPre);
class2 = class2.train(dataSetTrainPre);

% run the 2 classifiers on both the test and training data
class1OutTrain = class1.run(dataSetTrainPre);
class2OutTrain = class2.run(dataSetTrainPre);

class1OutTest = class1.run(dataSetTestPre);
class2OutTest = class2.run(dataSetTestPre);

% create, train and run a 3rd classifier who's input are the outputs of the
% first 2 classifiers?
class3 = prtClassMap;
class3InputTrain = catFeatures(class1OutTrain,class2OutTrain);
class3InputTest = catFeatures(class1OutTest,class2OutTest);

class3 = class3.train(class3InputTrain);

class3OutputTrain = class3.run(class3InputTrain);
class3OutputTest = class3.run(class3InputTest);

%% Do the same thing with an algorithm (look how clean!)
alg = prtPreProcZmuv + prtClassMap/prtClassGlrt + prtClassMap;
alg = alg.train(dataSetTrain);
algOut = alg.run(dataSetTest);

if(~isequal(algOut.getObservations, class3OutputTest.getObservations))
    result = false;
    disp('3 stage prtAlgorithm classification fail')
end
