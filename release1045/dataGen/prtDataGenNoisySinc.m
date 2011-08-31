function DataSet = prtDataGenNoisySinc
% prtDataGenNoisySinc Generates noisy sinc example data
%
%   DATASET = prtDataGenNoisySinc returns a prtDataSetRegress with 100
%   samples of sinc wave with zero-mean additive Gaussian noise. The noise
%   variance is .1.
%
%   Example:
%
%   ds = prtDataGenNoisySinc;
%   plot(ds)
%
%   See also: prtDataSetClass, prtDataGenBiModal, prtDataGenIris,
%   prtDataGenMary, prtDataGenNoisySinc, prtDataGenOldFaithful,
%   prtDataGenSpiral, prtDataGenUnimodal, prtDataGenUnimodal, prtDataGenXor



nSamples = 100;
noiseVar = 0.1;

t = linspace(-10,10,1000);
x = prtUtilRandSample(t,nSamples)';
t = sinc(x/pi);
y = t + noiseVar*randn(size(x));

DataSet = prtDataSetRegress(x,y,'name','Noisy Sinc');

function y = sinc(x)

y = sin(pi*x)./(pi*x);
y(x == 0) = 1;

function x = prtUtilRandSample(vector,nSamples)

ind = randperm(length(vector));
ind = ind(1:nSamples);
x = vector(sort(ind));