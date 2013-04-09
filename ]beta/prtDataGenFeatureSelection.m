function DataSet = prtDataGenFeatureSelection(N, nExtraDims)
%prtDataGenFeatureSelection   Generates some unimodal example data for the prt.
%  DataSet = prtDataGenFeatureSelection
%  The data is distributed:
%       H0: N([0 0 0 0 0 0 0 0 0 0],eye(10))
%       H1: N([0 2 0 1 0 2 0 1 0 2],eye(10))
%
% Syntax: [X, Y] = prtDataGenFeatureSelection(N)
%
% Inputs: 
%       N ~ number of samples per class (200)
%
% Outputs:
%   X - 2Nx2 Unimodal data
%   Y - 2Nx1 Class labels
%
% Example:
%   DataSet = prtDataGenFeatureSelection;
%   explore(DataSet)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: prtDataGenUnimodal

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



if nargin < 1 || isempty(N);
    nSamples = 200;
else
    nSamples = N;
end

if nargin < 2 || isempty(nExtraDims)
    nExtraDims = 0;
end

mu0 = [0 0 0 0 0 0 0 0 0 0];
mu1 = [0 1 0 .5 0 1 0 .5 0 1]*2;

sigma0 = eye(length(mu0));
sigma1 = eye(length(mu1));
rv(1) = prtRvMvn('mu',mu0,'sigma',sigma0);
rv(2) = prtRvMvn('mu',mu1,'sigma',sigma1);

X = cat(1,draw(rv(1),nSamples),draw(rv(2),nSamples));

if nExtraDims > 0
    rvNoise = prtRvMvn('mu',zeros(1,nExtraDims),'sigma',eye(nExtraDims));
    
    X = cat(2, X, rvNoise.draw(nSamples*2));
end

Y = prtUtilY(nSamples,nSamples);

DataSet = prtDataSetClass(X,Y,'name',mfilename);
