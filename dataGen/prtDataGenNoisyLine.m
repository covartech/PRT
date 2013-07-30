function DataSet = prtDataGenNoisyLine
% prtDataGenNoisyLine Generates noisy line example data
%
%   DATASET = prtDataGenNoisyLine returns a prtDataSetRegress with 100
%   samples of a line with zero-mean additive Gaussian noise. The noise
%   variance is .1.
%
%   Example:
%
%   ds = prtDataGenNoisyLine;
%   plot(ds)
%
%   See also: prtDataSetRegress, prtDataGenNoisySinc

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




nSamples = 100;
noiseVar = 0.1;

t = linspace(-1,1,1000);
x = prtUtilRandSample(t,nSamples)';
t = x;
y = t + noiseVar*randn(size(x));

DataSet = prtDataSetRegress(x,y,'name','Noisy Line');

function x = prtUtilRandSample(vector,nSamples)

ind = randperm(length(vector));
ind = ind(1:nSamples);
x = vector(sort(ind));
