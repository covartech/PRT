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
%   See also: prtDataSetRegress, prtDataGenBiModal, prtDataGenIris,
%   prtDataGenManual, prtDataGenMary, prtDataGenNoisySinc,
%   prtDataGenOldFaithful,prtDataGenProtate, prtDataGenSprial,
%   prtDataGenSpiral3 prtDataGenUnimodal, prtDataGenSwissRoll,
%   prtDataGenUnimodal, prtDataGenXor


nSamples = 100;
noiseVar = 0.1;

t = linspace(-10,10,1000);
x = randsample(t,nSamples)';
t = sinc(x/pi);
y = t + noiseVar*randn(size(x));

DataSet = prtDataSetRegress(x,y,'name','Noisy Sinc');