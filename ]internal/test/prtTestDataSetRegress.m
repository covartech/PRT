function result = prtTestDataSetRegress

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

% Test basic object instantiation
try
    dataSet = prtDataSetRegress;
    dataSet = dataSet.setObservationsAndTargets([ 1 2; 3 4], [0 1]');
catch
    disp('Instantiation of prtDataSetRegress fail')
    result = false;
end

% Check the results of above
if(dataSet.nFeatures ~= 2)
    disp('prtDataSetRegress nFeatures fail')
    result = false;
end

if(dataSet.isLabeled ~=1)
    disp('prtDataSetRegress isLabeled fail')
    result = false;
end

try
    out = dataSet.summarize;
catch
    disp('prtDataSetRegress summarize fail')
    result = false;
end

if ~isequal(out.upperBounds, [3 4]) || ~isequal(out.lowerBounds,[1 2])
    disp('prtDataSetRegress summarize fail')
    result = false;
end

% check that plotting works and errors properly
try
    % this should fail
    dataSet.plot()
     disp('prtDataSetRegress plot should error on higher dim data')
    result = false;
    close;
catch
    % no-op
end

dataSet = prtDataGenNoisySinc;
try
    dataSet.plot()
    close;
catch
    result = false; 
    close
    disp('prtDataSetRegress fail')
end
    
