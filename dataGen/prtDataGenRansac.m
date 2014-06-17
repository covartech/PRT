function DataSet = prtDataGenRansac(N,pOutlier)
%DataSet = prtDataGenRansac(N,pOutlier)
%
%   DataSet = prtDataGenRansac(100,0.2)
%
%   plot(DataSet);
%   axis equal;

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


if nargin == 0
	N = 100;
end
if nargin < 1
	pOutlier = 0.1;
end
nSamples = N;

covMat = [1 0.999; 0.999 1];
R = prtRvMvn('mu',[0 0],'sigma',covMat);
inliers = draw(R,ceil(nSamples*(1-pOutlier)));
inlierLabels = ones(ceil(nSamples*(1-pOutlier)),1);

covMat = [sqrt(2) 0; 0 sqrt(2)];
R = prtRvMvn('mu',[0 0],'sigma',covMat);
outliers = draw(R,floor(nSamples*pOutlier));
outlierLabels = zeros(floor(nSamples*pOutlier),1);

DataSet = prtDataSetRegress(cat(1,inliers(:,1),outliers(:,1)),...
	cat(1,inliers(:,2),outliers(:,2)),...
	'name','prtDataGenRansac',...
	'observationInfo',struct('inlier',num2cell(cat(1,inlierLabels,outlierLabels))));
