function result = prtTestAlgorithm
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

if ~isequal(resultAlg, resultClass)
    disp('prtAlgorithm basic classification not equal to prtClass result')
    result = false;
end


%% now try 2 stage classifier. Feature reduction followed by classification
featSel = prtFeatSelStatic;
featSel.selectedFeatures = 1;

dataSetSelTest = featSel.run(dataSetTest);
dataSetSelTrain = featSel.run(dataSetTrain);

% Create a classifier
class = prtClassMap;
class = class.train(dataSetSelTrain);
resultClass = class.run(dataSetSelTest);

% now do the same thing with a prtAlgorithm
alg = prtAlgorithm;
alg = alg + featSel;
alg = alg + prtClassMap;

alg = alg.train(dataSetTrain);
resultAlg = alg.run(dataSetTest);

if(~isequal(resultAlg, resultClass))
    result = false;
    disp('2 stage prtAlgorithm classification fail')
end

%% test a pre-processor, 2 paralell classifiers, followed by a 3rd
%% classifier, oh my.

preProc = prtPreProcZmuv;

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
% what the hell
