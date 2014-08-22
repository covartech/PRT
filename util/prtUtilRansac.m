function [bestAlgo, inliers] = prtUtilRansac(data,algo,evalFn,varargin)
%[bestAlgo, inliers] = prtUtilRansac(data,algo,evalFn)
%   Perform RANSAC on prtDataSet data.
%
%[bestAlgo, inliers] = prtUtilRansac(data,algo,evalFn,param1,value1,...)
%   Enables inputs of parameter/value pairs as described below:
%
%   Parameters:
%       nIterations (100)
%       nBootstrapSamples (10) - the number of samples to use at each
%         iteration to fit a model.
%       fitErrorThreshold (0.2) - absolute error between truth and guess
%         should be less than fitErrorThreshold to be included inliers.
%
%   Example usage:
%
%       ds = prtDataGenRansac(100,0.2);
%       [~,inliers] = prtUtilRansac(ds,prtRegressLslr,@(a,b)abs(a-b));
%       plot(ds.X(inliers),ds.Y(inliers),'ro',...
%            ds.X(setdiff(1:100,inliers)),ds.Y(setdiff(1:100,inliers)),'bs')

% Copyright (c) 2014 Patrick Wang, Peter Torrione, Kenneth Morton
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

%% parse input options
p = inputParser;

p.addParamValue('nIterations',100);
p.addParamValue('nBootstrapSamples',10);
p.addParamValue('fitErrorThreshold',0.2);

p.parse(varargin{:});
inputStructure = p.Results;

%% iterate
bestNFit = 0;

for iter = 1:inputStructure.nIterations
	% bootstrap
	indices = randperm(data.nObservations);
	indices = indices(1:inputStructure.nBootstrapSamples);
	dataIn = data.retainObservations(indices);
	dataOut = data.removeObservations(indices);
	
	% train on bootstrapped samples
	algoTrained = algo.train(dataIn);
	
	% test on left-out samples
	guessOut = algoTrained.run(dataOut);
	
	% find how many left-out samples fit model well
	error = evalFn(guessOut.X,dataOut.Y); % dataOut.Y?
	nFit = sum(error<inputStructure.fitErrorThreshold);
	
	% keep the best model
	if nFit>bestNFit
		bestNFit = nFit;
		bestAlgo = algoTrained;
	end
end

%% find all inliers and retrain model
guess = bestAlgo.run(data);
error = evalFn(guess.X,data.Y); % data.Y?
inliers = find(error<inputStructure.fitErrorThreshold);
bestAlgo = algo.train(data.retainObservations(inliers));