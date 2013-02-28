function [DataSet,pcaVectors] = prtDataGenPca(N)
%[DataSet,pcaVectors] = prtDataGenPca(N)
%
%   [DataSet,truePcaVectors] = prtDataGenPca(300);
%   tpv = truePcaVectors;
%   pca = prtPreProcPca;
%   pca = pca.train(DataSet);
%
%   plot(DataSet);
%   hold on;
%   h1 = plot([0,tpv(1,1)],[0,tpv(2,1)],'b',[0,tpv(1,2)],[0,tpv(2,2)],'r');
%   epv = pca.pcaVectors;
%   h2 = plot([0,epv(1,1)],[0,epv(2,1)],'b:',[0,epv(1,2)],[0,epv(2,2)],'r:');
%
%   set([h1,h2],'linewidth',3);
%   axis equal;

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

covMat = [1 .9; .9 1];
R(1,1) = prtRvMvn('mu',[0 0],'sigma',covMat);

[v,e] = eig([1 .9; .9 1]);
[~,sortInds] = sort(diag(e),'descend');
pcaVectors = v(:,sortInds);

X = draw(R(1,1),nSamples);
Y = [];

DataSet = prtDataSetClass(X,Y,'name','prtDataGenPca');
