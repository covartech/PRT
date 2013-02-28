function DataSet = prtDataGenBimodal(N)
%prtDataGenBimodal   Generate bimodal example data 
%
%  DATASET = prtDataGenBimodal returns a prtDataSetClass with randomly
%  generated data according to the following distribution.
%
%       H0: 1/2N([0 0],eye(2)) + 1/2*N([-4 -4],eye(2))
%       H1: 1/2N([2 2],[1 .5; .5 1]) + 1/2*N([-2 -2],[1 .5; .5 1]
%
%  Example:
%
%  dataSet = prtDataGenBimodal;
%  plot(dataSet)
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


if nargin == 0
	N = 100;
end
nSamples = N;

R(1,1) = prtRvMvn('mu',[0 0],'sigma',eye(2));
R(1,2) = prtRvMvn('mu',[-4 -4],'sigma',eye(2));
R(2,1) = prtRvMvn('mu',[2 2],'sigma',[1 .5; .5 1]);
R(2,2) = prtRvMvn('mu',[-2 -2],'sigma',[1 .5; .5 1]);

X = cat(1,draw(R(1,1),nSamples),draw(R(1,2),nSamples),draw(R(2,1),nSamples),draw(R(2,2),nSamples));
Y = prtUtilY(nSamples*2, nSamples*2);

DataSet = prtDataSetClass(X,Y,'name','prtDataGenBimodal');
