function result = prtTestPreProcZmuv

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
    dataSet = prtDataGenProstate;       % Load a data set.
    zmuv = prtPreProcZmuv;           %  Create a zero-mean unit variance
    %  object
    zmuv = zmuv.train(dataSet);      % Compute the mean and variance
    dataSetNew = zmuv.run(dataSet);  % Normalize the data
catch
    disp('basic zmuv failure')
    result = false;
end
if  abs(mean(dataSetNew.getObservations())) > 1e-13
    result = false;
    disp('zmuv mean not zero')
end

if  abs(1-var(dataSetNew.getObservations())) > 1e-13      %Check the variance
    result = false;
    disp('zmuv variance not 1');
end
