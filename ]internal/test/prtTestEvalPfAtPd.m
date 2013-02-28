function result = prtTestEvalPfAtPd
% This function tests prtEvalPfAtPd

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
    score = prtEvalPfAtPd(classifier,dataSet,.9);
catch
    disp('error #1, prtEvalPfAtPd failed basic operation')
    result = false;
end

% check score
% Should be around .99 for the above run
if( abs(score - .99)< .01) 
    disp('error #2, prtEvalPfAtPd wrong score')
    result = false;
end


% Basic operation, kfolds
try
    dataSet = prtDataGenSpiral;
    classifier = prtClassDlrt;
    score = prtEvalPfAtPd(classifier,dataSet,.9 ,10);
catch
    disp('error #2, prtScorePfAtPdKfolds failed basic operation')
    result = false;
end

% check score
% Should be around .99 for the above run
if( abs(score - .99) < .01) 
    disp('error #3, prtScorePfAtPdKfolds wrong score')
    result = false;
end

%% Error checks
error = true;

% try an unlabeld dataSet
dataSet = prtDataSetClass;
dataSet = dataSet.setX(rand(2,2));
classifier = prtClassDlrt;

try
    score = prtEvalPfAtPd(classifier,dataSet,.9);
    error = false;
    disp('Error #4, unlabeled data set')
catch
    % no-op
    prtUtilProgressBar.forceClose();
end
    

% try wrong order input args

try
     pf = prtEvalPdAtPf(dataSet,classifier,.01); 
     error = false;
     disp('Error #5, input arg check')
catch
    % no0op
    prtUtilProgressBar.forceClose();
end
result = result & error;
