function DataSet = prtDataGenXor(N)
%prtDataGenXor  Generates XOR example data
%
%   DATASET = prtDataGenXor returns a prtDataSetClass with randomly
%   generated data according to the following distribution.
%
%       H0: N([-1 -1],eye(2))
%       H1: N([2 2],[1 .5; .5 1])
%
%   % Example
% 
%   ds = prtDataGenXor;
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
    mu01 = [0 3];
    sigma01 = eye(2)/3;
    mu02 = [3 0];
    sigma02 = eye(2)/3;
    
    mu11 = [3 3];
    sigma11 = eye(2)/3;
    mu12 = [0 0];
    sigma12 = eye(2)/3;
end
rv(1) = prtRvMvn('Mean',mu01,'Covariance',sigma01);
rv(2) = prtRvMvn('Mean',mu02,'Covariance',sigma02);

rv(3) = prtRvMvn('Mean',mu11,'Covariance',sigma11);
rv(4) = prtRvMvn('Mean',mu12,'Covariance',sigma12);

X = cat(1,draw(rv(1),nSamples/2),draw(rv(2),nSamples/2),draw(rv(3),nSamples/2),draw(rv(4),nSamples/2));
Y = prtUtilY(nSamples,nSamples);

DataSet = prtDataSetClass(X,Y,'name','XOR Data');