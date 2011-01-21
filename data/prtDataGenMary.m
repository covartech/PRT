function DataSet = prtDataGenMary
% prtDataGenMary  Generate unimodal M-ary example data
%
%  DATASET = prtDataGenMary returns a prtDataSetClass with randomly
%  generated data according to the following distribution.
%
%       H1: N([0 0],0.5*eye(2))
%       H2: N([0.5 0.5],0.1*eye(2))
%       H3: N([-2 -2],eye(2))
%
%  Example:
%
%  ds = prtDataGenMary;
%  plot(ds)
%
%   See also: prtDataSetClass, prtDataGenBiModal, prtDataGenIris,
%   prtDataGenManual, prtDataGenMary, prtDataGenNoisySinc,
%   prtDataGenOldFaithful,prtDataGenProtate, prtDataGenSprial,
%   prtDataGenSpiral3 prtDataGenUnimodal, prtDataGenSwissRoll,
%   prtDataGenUnimodal, prtDataGenXor


% Copyright 2010, New Folder Consulting, L.L.C.

rvH1 = prtRvMvn('Mean',[0 0],'Covariance',0.5*eye(2));
rvH2 = prtRvMvn('Mean',[0.5 0.5],'Covariance',0.1*eye(2));
rvH3 = prtRvMvn('Mean',[-2 -2],'Covariance',eye(2));
X = cat(1,draw(rvH1,100),draw(rvH2,100),draw(rvH3,100));
Y = prtUtilY(0,100,100,100);

DataSet = prtDataSetClass(X,Y,'name','prtDataGenMary');
