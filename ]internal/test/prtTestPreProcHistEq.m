function result = prtTestPreProcHistEq

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

try
    dataSet = prtDataGenIris;              % Load a data set
    dataSet = dataSet.retainFeatures(1:2); % Use only the first 2
    % Features
    histEq = prtPreProcHistEq;             % Create the
    % prtPreProcHistEq Object
    
    histEq = histEq.train(dataSet);        % Train the object
    dataSetNew = histEq.run(dataSet);      % Equalize the histogram
    
catch
    disp('basic hist eq failure')
    result = false;
end
if  any(max(dataSetNew.getX) > 1.1)
    result = false;
    disp('pre proc hist eq much greater than 1')
end

if  any(min(dataSetNew.getX) <-.1)
    result = false;
    disp('pre proc hist eq much less than 0')
end

% Check that we can change the # of samples
try
    histEq.nSamples = 100;
    histEq = prtPreProcHistEq;             % Create the
    % prtPreProcHistEq Object
    
    histEq = histEq.train(dataSet);        % Train the object
    dataSetNew = histEq.run(dataSet);      % Equalize the histogram
catch
    result = false;
    disp('pre proc hist eq n samples')
end
