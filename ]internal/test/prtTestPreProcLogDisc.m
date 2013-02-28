function result = prtTestPreProcLogDisc

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
    dataSet = prtDataGenUnimodal;     % Load a data set
    logDisc = prtPreProcLogDisc;      % Create a pre processing object
    
    logDisc = logDisc.train(dataSet);  % Train
    dataSetNew = logDisc.run(dataSet); % Run
catch
    result = false;
    disp('prtTestLogDisc basic fail')
end

% Check that the mins are 0 and the max are 1's

if  any(abs(min(dataSetNew.getX())) > 1e-3*[ 1 1])
    result = false;
    disp('log dis min not zero')
end

if  any(abs(1-max(dataSetNew.getX())) >1e-3*[ 1 1])     %Check the max
    result = false;
    disp('log disc max not 1');
end
