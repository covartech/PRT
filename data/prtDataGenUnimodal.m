function DataSet = prtDataGenUnimodal(N,mu0,mu1,sigma0,sigma1)
%prtDataGenUnimodal   Generates unimodal example data
%
%   DATASET = prtDataGenUnimodal returns a prtDataSetClass with randomly
%   generated data according to the following distribution.
%
%       H0: N([-1 -1],eye(2))
%       H1: N([2 2],[1 .5; .5 1])
%
%   % Example
%
%   ds = prtDataGenUniModal;
%   plot(ds)
%   
%   See also: prtDataSetClass, prtDataGenBiModal, prtDataGenIris,
%   prtDataGenManual, prtDataGenMary, prtDataGenNoisySinc,
%   prtDataGenOldFaithful,prtDataGenProtate, prtDataGenSprial,
%   prtDataGenSpiral3 prtDataGenUnimodal, prtDataGenSwissRoll,
%   prtDataGenUnimodal, prtDataGenXor

% Copyright 2010, New Folder Consulting, L.L.C.

if nargin == 0
    nSamples = 200;
else
    nSamples = N;
end
if nargin < 5
    mu0 = [-1 -1];
    sigma0 = eye(2);
    mu1 = [2 2];
    sigma1 = [1 .5; .5 1];
end
rv(1) = prtRvMvn('Mean',mu0,'Covariance',sigma0);
rv(2) = prtRvMvn('Mean',mu1,'Covariance',sigma1);

X = cat(1,draw(rv(1),nSamples),draw(rv(2),nSamples));
Y = prtUtilY(nSamples,nSamples);

DataSet = prtDataSetClass(X,Y,'name',mfilename);