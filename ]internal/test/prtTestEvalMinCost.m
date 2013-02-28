function result = prtTestEvalMinCost
% This function tests prtEvalMinCost

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

% Basic operation
try
    dataSet = prtDataGenSpiral;
    classifier = prtClassDlrt;
    cost = [0 1;1 0];
    score = prtEvalMinCost(classifier,dataSet,cost);
catch
    disp('error #1, prtEvalMinCost failed basic operation')
    result = false;
end

% check score
% Should be around .99 for the above run
if( abs(score - .99)< .01) 
    disp('error #2, prtEvalMinCost wrong score')
    result = false;
end


% Basic operation, kfolds
try
    dataSet = prtDataGenSpiral;
    classifier = prtClassDlrt;
    cost = [0 1;1 0];
    score = prtEvalMinCost(classifier,dataSet,cost, 10);
catch
    disp('error #2, prtScoreMinCostKfolds failed basic operation')
    result = false;
end

% check score
% Should be around .99 for the above run
if( abs(score - .99) < .05) 
    disp('error #3, prtScoreMinCostKfolds wrong score')
    result = false;
end


dataSet = prtDataGenSpiral;
classifier = prtClassDlrt;
cost = [0 1;1 0];
[score, pf, pd] = prtEvalMinCost(classifier,dataSet,cost, 10);

if( abs(pf - .05) > .05)
    disp('error #3, prtScoreMinCostPf wrong score')
    result = false;
end

if( abs(pd - .965) > .05)
    disp('error #3, prtScoreMinCostPd wrong score')
    result = false;
end

%% Error checks
error = true;

% try an unlabeld dataSet
dataSet = prtDataSetClass;
dataSet = dataSet.setX(rand(2,2));
classifier = prtClassDlrt;

try
    score = prtEvalMinCost(classifier,dataSet, cost);
    error = false;
    disp('Error #4, unlabeled data set')
catch
    % no-op
    prtTestClassRvmFigueiredo
end
    

% try wrong order input args

try
     pf = prtEvalPdAtPf(dataSet,classifier, cost); 
     error = false;
     disp('Error #5, input arg check')
catch
    % no0op
    prtTestClassRvmFigueiredo
end
result = result & error;
