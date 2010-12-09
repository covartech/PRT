function prtTestDecisionBinaryMinPe
result = true;

dsTrain = prtDataGenUnimodal;
dsTest = prtDataGenUnimodal;

% Try the algorithm technique
try
    algo = prtClassKnn + prtDecisionBinaryMinPe;
    algo = algo.train(dsTrain);
    outAlgo = algo.run(dsTest);
catch
    result = false;
    disp('prtTestDecisionBinaryMinPe algo fail')
end

try
    myKnn = prtClassKnn;
    myKnn.internalDecider = prtDecisionBinaryMinPe;
    myKnn = myKnn.train(dsTrain);
    outIntDec = myKnn.run(dsTest);
catch
    result = false;
    disp('prtTestDecisionBinaryMinPe internal dec fail')
    result = false;
end

% check that the results are the same
% Which are the class labels????
if ~isequal(outAlgo.getX, outIntDec.getX)
    result = false;
    disp('prtTestDecisionBinaryMinPe algo/int not equal')
end

% check that plot works in both cases
try
    algo.plot;
    close all;
catch
    disp('prtDecisionBinaryMinPe algo plot fail');
    close all
    result = false;
end


% check that plot works in both cases
try
    myKnn.plot;
    close all;
catch
    disp('prtDecisionBinaryMinPe internal decider plot fail');
    close all
    result = false;
end
