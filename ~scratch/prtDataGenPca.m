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

if nargin == 0
	N = 100;
end
nSamples = N;

covMat = [1 .9; .9 1];
R(1,1) = prtRvMvn('Mean',[0 0],'Covariance',covMat);

[v,e] = eig([1 .9; .9 1]);
[~,sortInds] = sort(diag(e),'descend');
pcaVectors = v(:,sortInds);

X = draw(R(1,1),nSamples);
Y = [];

DataSet = prtDataSetClass(X,Y,'name','prtDataGenPca');