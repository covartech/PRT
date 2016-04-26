function DataSet = prtDataGenNoisyLine(varargin)
% prtDataGenNoisyLine Generates noisy line example data
%
%   DATASET = prtDataGenNoisyLine returns a prtDataSetRegress with 100
%   samples of a line on x = [-1, 1] with zero-mean additive Gaussian
%   noise. By default, the slope is 1 and the y-intercept is 0. The noise
%   variance is .1.
%
%   DATASET = prtDataGenNoisyLine(slope, y_intercept) returns a
%   prtDataSetRegress with 100 samples of a line on x = [-1, 1] with
%   zero-mean additive Gaussian noise. The noise variance is .1.
%
%   Example:
%
%   ds = prtDataGenNoisyLine;
%   plot(ds)
%
%   See also: prtDataSetRegress, prtDataGenNoisySinc






if nargin~=2
	slope = 1;
	y_intercept = 0;
else
	slope = varargin{1};
	y_intercept = varargin{2};
end

nSamples = 100;
noiseVar = 0.1;

t = linspace(-1,1,1000);
x = prtUtilRandSample(t,nSamples)';
t = x*slope + y_intercept;
y = t + noiseVar*randn(size(x));

DataSet = prtDataSetRegress(x,y,'name','Noisy Line');

function x = prtUtilRandSample(vector,nSamples)

ind = randperm(length(vector));
ind = ind(1:nSamples);
x = vector(sort(ind));
