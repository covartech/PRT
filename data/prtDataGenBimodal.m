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
% See also: prtDataSetClass, prtDataGenCircles, prtDataGenIris,
% prtDataGenManual, prtDataGenMary, prtDataGenNoisySinc,
% prtDataGenOldFaithful,prtDataGenProtate, prtDataGenSprial,
% prtDataGenSpiral3Regress prtDataGenUnimodal, prtDataGenSwissRoll,
% prtDataGenUnimodal, prtDataGenXor

% Copyright 2010, New Folder Consulting, L.L.C.

if nargin == 0
	N = 100;
end
nSamples = N;

R(1,1) = prtRvMvn('Mean',[0 0],'Covariance',eye(2));
R(1,2) = prtRvMvn('Mean',[-4 -4],'Covariance',eye(2));
R(2,1) = prtRvMvn('Mean',[2 2],'Covariance',[1 .5; .5 1]);
R(2,2) = prtRvMvn('Mean',[-2 -2],'Covariance',[1 .5; .5 1]);

X = cat(1,draw(R(1,1),nSamples),draw(R(1,2),nSamples),draw(R(2,1),nSamples),draw(R(2,2),nSamples));
Y = prtUtilY(nSamples*2, nSamples*2);

DataSet = prtDataSetClass(X,Y,'name','prtDataGenBimodal');