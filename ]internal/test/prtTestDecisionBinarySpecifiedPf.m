function result = prtTestDecisionBinarySpecifiedPf
result = true;

dsTrain = prtDataGenUnimodal;
dsTest = prtDataGenUnimodal;

% Try the algorithm technique
try
    algo = prtClassKnn;
    dec  =  prtDecisionBinarySpecifiedPf;
    dec.pf =.5;
    algo = algo + dec;
    algo = algo.train(dsTrain);
    outAlgo = algo.run(dsTest);
catch
    result = false;
    disp('prtDecisionBinarySpecifiedPf algo fail')
end

try
    myKnn = prtClassKnn;
    myKnn.internalDecider = prtDecisionBinarySpecifiedPf;
    myKnn.internalDecider.pf = .5;
    myKnn = myKnn.train(dsTrain);
    outIntDec = myKnn.run(dsTest);
catch
    result = false;
    disp('prtDecisionBinarySpecifiedPf internal dec fail')
    result = false;
end

% check that the results are the same
% Which are the class labels????
if ~isequal(outAlgo.getX, outIntDec.getX)
    result = false;
    disp('prtDecisionBinarySpecifiedPf algo/int not equal')
end

% check that plot works in both cases
try
    algo.plot;
    close all;
catch
    disp('prtDecisionBinarySpecPf algo plot fail');
    close all
    result = false;
end


% check that plot works in both cases
try
    myKnn.plot;
    close all;
catch
    disp('prtDecisionBinarySpecPf internal decider plot fail');
    close all
    result = false;
end

% check that errors when pf not set
try
    
    dsTrain = prtDataGenUnimodal;
    dsTest = prtDataGenUnimodal;
    myKnn = prtClassKnn;
    myKnn.internalDecider = prtDecisionBinarySpecifiedPf;
    myKnn = myKnn.train(dsTrain);
    outIntDec = myKnn.run(dsTest);
    disp('prtDecisionBinarySpecPf runs with unset pf')
    result = false;
catch
    %noop
end