function result = prtTestKernelRbf

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
    kern = prtKernelRbf;
    ds = prtDataGenBimodal;
    kern = kern.train(ds);
    kernOut = kern.run(ds);
catch ME
    disp(ME)
    disp('basic rbf kernel failure')
    result = false;
end


if all(diag(kernOut.getX) ~= ones(size(kernOut.getX,2),1))
    disp('rbf kernel higher dim wrong answer')
    result = false;
end

% check answer for scalar

ds = prtDataSetStandard('observations',1);
ds1 = prtDataSetStandard('observations', 2);
kern = prtKernelRbf;
kern = kern.train(ds);
out = kern.run(ds1);

if ~isequal(out.getX, exp(-1))
    disp('prt kernel rbf wrong answer for scalar')
    result = false;
end

% Check it for 1 element vector
ds = prtDataSetStandard('observations',[1 1]);
ds1 = prtDataSetStandard('observations', [2 2]);
kern = prtKernelRbf;
kern = kern.train(ds);
out = kern.run(ds1);

dist = prtDistanceEuclidean([1 1], [2 2 ]);
if  (exp(-(dist.^2)) - out.getX) > 1e-15
    result = false;
    disp('prt rbf kernel wrong answer vector')
end
% check to string
try
    str = kern.toString;
catch ME
    disp(ME)
    disp('rbf kern toString fail')
    result = false;
end
if ~isa(str, 'char')
    disp('rbf kernel toString not a string')
    result = false;
end


%% Erorr checks
error = true;
% Check that it errors out when not initialized
kern = prtKernelRbf;
try
    kern.run(1);
    disp('rbf kernel run before init')
    error = false;
catch
    %% 
end
result = result && error;
