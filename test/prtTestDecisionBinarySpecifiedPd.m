function result = prtTestDecisionBinarySpecifiedPd
result = true;

dsTrain = prtDataGenUnimodal;
dsTest = prtDataGenUnimodal;

% Try the algorithm technique
try
    algo = prtClassKnn;
    dec  =  prtDecisionBinarySpecifiedPd;
    dec.pd =.5;
    algo = algo + dec;
    algo = algo.train(dsTrain);
    outAlgo = algo.run(dsTest);
catch
    result = false;
    disp('prtDecisionBinarySpecifiedPd algo fail')
end

try
    myKnn = prtClassKnn;
    myKnn.internalDecider = prtDecisionBinarySpecifiedPd;
    myKnn.internalDecider.pd = .5;
    myKnn = myKnn.train(dsTrain);
    outIntDec = myKnn.run(dsTest);
catch
    result = false;
    disp('prtDecisionBinarySpecifiedPd internal dec fail')
    result = false;
end

% check that the results are the same
% Which are the class labels????
if ~isequal(outAlgo.getX, outIntDec.getX)
    result = false;
    disp('prtDecisionBinarySpecifiedPd algo/int not equal')
end

% check that plot works in both cases
try
    algo.plot;
    close all;
catch
    disp('prtDecisionBinarySpecPd algo plot fail');
    close all
    result = false;
end


% check that plot works in both cases
try
    myKnn.plot;
    close all;
catch
    disp('prtDecisionBinarySpecPd internal decider plot fail');
    close all
    result = false;
end

% check that errors when pd not set
try
    
    dsTrain = prtDataGenUnimodal;
    dsTest = prtDataGenUnimodal;
    myKnn = prtClassKnn;
    myKnn.internalDecider = prtDecisionBinarySpecifiedPd;
    myKnn = myKnn.train(dsTrain);
    outIntDec = myKnn.run(dsTest);
    disp('prtDecisionBinarySpecPd runs with unset pd')
    result = false;
catch
    %noop
end