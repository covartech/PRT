function result = prtTestDecisionMap
result = true;

dsTrain = prtDataGenMary;
dsTest = prtDataGenMary;

% Try the algorithm technique
try
    algo = prtClassKnn + prtDecisionMap;
    algo = algo.train(dsTrain);
    outAlgo = algo.run(dsTest);
catch
    result = false;
    disp('prtTestDecisionMap algo fail')
end

try
    myKnn = prtClassKnn;
    myKnn.internalDecider = prtDecisionMap;
    myKnn = myKnn.train(dsTrain);
    outIntDec = myKnn.run(dsTest);
catch
    result = false;
    disp('prtTestDecisionMap internal dec fail')
    result = false;
end

% check that the results are the same
% Which are the class labels????
if ~isequal(outAlgo.getX, outIntDec.getX)
    result = false;
    disp('prtTestDecisionMap algo/int not equal')
end

% check that plot works in both cases
try
    algo.plot;
    close all;
catch
    disp('prtDecisionMap algo plot fail');
    close all
    result = false;
end


% check that plot works in both cases
try
    myKnn.plot;
    close all;
catch
    disp('prtDecisionMap internal decider plot fail');
    close all
    result = false;
end
