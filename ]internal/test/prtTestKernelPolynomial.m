function result = prtTestKernelPolynomial

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


% basic kernel implention, should work

try
    kern = prtKernelPolynomial;
    ds = prtDataGenBimodal;
    kern = kern.train(ds);
    kernOut = kern.run(ds);
catch ME
    disp(ME)
    disp('basic polynomial kernel failure')
    result = false;
end

% Check that i can set params
try
    kern.d = 1;
    kern.c = 2;
    kern = kern.train(ds);
    kernOut = kern.run(ds);
catch ME
    disp(ME)
    disp('polynomial kernel fail')
    result = false
end


kern.d = 2; kern.c = 0;
ds = prtDataSetClass;
ds = ds.setObservations([1 2 3]');
kern = kern.train(ds);
kernOut = kern.run(ds);
if kernOut.getX ~= [ 1 4 9; 4 16 36; 9 36 81]
    disp('poly kern wrong output')
    result = false;
end

% check to string
try
    str = kern.toString;
catch ME
    disp(ME)
    disp('poly kern toString fail')
    result = false;
end
if ~isa(str, 'char')
    disp('poly kernel toString not a string')
    result = false;
end


%% Erorr checks
error = true;
% Check that it errors out when not initialized
kern = prtKernelPolynomial;
try
    kern.run(1);
    disp('poly kernel run before init')
    error = false;
catch
    %%
end
result = result && error;
