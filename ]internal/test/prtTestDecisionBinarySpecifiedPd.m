function result = prtTestDecisionBinarySpecifiedPd

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
