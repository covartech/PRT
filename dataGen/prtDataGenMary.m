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
%   prtDataGenMary, prtDataGenNoisySinc, prtDataGenOldFaithful,
%   prtDataGenSpiral, prtDataGenUnimodal, prtDataGenUnimodal, prtDataGenXor








rvH1 = prtRvMvn('mu',[0 0],'sigma',0.5*eye(2));
rvH2 = prtRvMvn('mu',[0.5 0.5],'sigma',0.1*eye(2));
rvH3 = prtRvMvn('mu',[-2 -2],'sigma',eye(2));
X = cat(1,draw(rvH1,100),draw(rvH2,100),draw(rvH3,100));
Y = prtUtilY(0,100,100,100);

DataSet = prtDataSetClass(X,Y,'name','prtDataGenMary');
