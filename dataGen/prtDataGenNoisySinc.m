function DataSet = prtDataGenNoisySinc(varargin)
% prtDataGenNoisySinc Generates noisy sinc example data
%
%   DATASET = prtDataGenNoisySinc returns a prtDataSetRegress with 100
%   samples of sinc wave with zero-mean additive Gaussian noise. The noise
%   variance is .1.
%
%   DATASET = prtDataGenNoisySinc(param,value) enables specification of
%   various parameter/value pairs:
%       nSamples - 100 - the number of random locations to sample
%       tLims - [-10 10] - 1x2 vector specifying x sampling range
%       x - [] - nx1 vector of locations to sample at; if empty, use random
%           sampling, which uses nSamples and t to randomly pick x.
%       noiseVar - 0.1 - the variance of the noise to add
%       
%
%   Example:
%
%   ds1 = prtDataGenNoisySinc;
%   ds2 = prtDataGenNoisySinc('tLims',[-5 5],'nSamples',1000);
%   ds3 = prtDataGenNoisySinc('x',linspace(-10,10,30));
%   subplot(3,1,1); 
%   plot(ds1); 
%   V = axis;
%   subplot(3,1,2);
%   plot(ds2); 
%   axis(V);
%   subplot(3,1,3);
%   plot(ds3); 
%   axis(V);
%
%   See also: prtDataSetClass, prtDataGenBiModal, prtDataGenIris,
%   prtDataGenMary, prtDataGenNoisySinc, prtDataGenOldFaithful,
%   prtDataGenSpiral, prtDataGenUnimodal, prtDataGenUnimodal, prtDataGenXor

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


if nargin == 1
    nSamples = varargin{1};
    noiseVar = 0.1;
    tLims = [-10 10];
    x = prtUtilRandSample(tLims,nSamples);
else
    p = inputParser;
    p.addParameter('noiseVar',.1);
    p.addParameter('nSamples',100);
    p.addParameter('tLims',[-10 10]);
    p.addParameter('x',[]);
    p.parse(varargin{:});
    inputs = p.Results;
    noiseVar = inputs.noiseVar;
    nSamples = inputs.nSamples;
    tLims = inputs.tLims;
    x = inputs.x;
    x = x(:);
    if isempty(x);
        x = prtUtilRandSample(tLims,nSamples);
    end
end

t = sinc(x/pi);
y = t + noiseVar*randn(size(x));

DataSet = prtDataSetRegress(x,y,'name','Noisy Sinc');

function y = sinc(x)

y = sin(pi*x)./(pi*x);
y(x == 0) = 1;

function x = prtUtilRandSample(tLims,nSamples)

x = rand(nSamples,1)*(tLims(2)-tLims(1)) + tLims(1);
