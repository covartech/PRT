function DataSet = prtDataGenSpiral3Regress
%prtDataGenSpiral3Regress   Generates some spirally clustered example data 
%
%  DATASET = prtDataGenSpiral3Regress returns a prtDataSetClass with randomly
%  generated data in a spiral pattern in 3 dimensions.
%
%  Example:
%
%  ds = prtDataGenSpiral3Regress;
%
%   See also: prtDataSetClass, prtDataGenBiModal, prtDataGenIris,
%   prtDataGenManual, prtDataGenMary, prtDataGenNoisySinc,
%   prtDataGenOldFaithful,prtDataGenProtate, prtDataGenSprial,
%   prtDataGenSpiral3Regress, prtDataGenUnimodal, prtDataGenSwissRoll,
%   prtDataGenUnimodal, prtDataGenXor







% Generates the spiral data set used in Ueda et al. 2000.  It consists of a
% 1 dimensional manifold in 3 dimensions with additive noise.

nSamples = 800;
t = rand(nSamples,1)*4*pi;
t = sort(t);

X = [(13-0.5*t).*cos(t) -(13-0.5*t).*sin(t) t] + mvnrnd(zeros(3,1),0.5*eye(3),nSamples);
Y = t;

DataSet = prtDataSetRegress(X,Y,'name','prtDataGenSpiral3');
