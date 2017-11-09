function DataSet = prtDataGenNoisyLine(varargin)
% prtDataGenNoisyLine Generates noisy line example data
%
%   DATASET = prtDataGenNoisyLine returns a prtDataSetRegress with 100
%   samples of a line on x = [-1, 1] with zero-mean additive Gaussian
%   noise. By default, the slope is 1 and the y-intercept is 0. The noise
%   variance is .1.
%
%   DATASET = prtDataGenNoisyLine(param,val) enables setting the following
%   parameters:
%       slope: 1
%       yIntercept: 0
%       xRange: [-1, 1]
%       xRange: [-1, 1]
%       nSamples: 1000
%       stdev: 0.1
%
%   Example:
%
%   ds = prtDataGenNoisyLine;
%   plot(ds)
%
%   See also: prtDataSetRegress, prtDataGenNoisySinc



p = inputParser;
p.addParameter('slope',1);
p.addParameter('yIntercept',0);
p.addParameter('xRange',[-1 1]);
p.addParameter('nSamples',100);
p.addParameter('stdev',0.1);

p.parse(varargin{:});

x = rand(p.Results.nSamples,1)*range(p.Results.xRange)+p.Results.xRange(1);
t = x*p.Results.slope + p.Results.yIntercept;
y = t + p.Results.stdev*randn(size(x));

DataSet = prtDataSetRegress(x,y,'name','Noisy Line');

% function x = prtUtilRandSample(vector,nSamples)
% 
% ind = randperm(length(vector));
% ind = ind(1:nSamples);
% x = vector(sort(ind));
