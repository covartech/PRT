function DataSet = prtDataGenSpiral(N)
%prtDataGenSpiral   Generates some spirally clustered example data 
%
%  DATASET = prtDataGenSpiral returns a prtDataSetClass with randomly
%  generated data in a spiral pattern in 2 dimensions.
%
%  Example:
%
%  ds = prtDataGenSpiral;
%  plot(ds)
%
%   See also: prtDataSetClass, prtDataGenBiModal, prtDataGenIris,
%   prtDataGenMary, prtDataGenNoisySinc, prtDataGenOldFaithful,
%   prtDataGenSpiral, prtDataGenUnimodal, prtDataGenUnimodal, prtDataGenXor









if nargin < 1
    nSamples = 200;
else 
    nSamples = N;
end
t = linspace(0,4*pi,nSamples);
f = 1;
dx = .5;
dy = .5;
std = .1;

theta1 = 0;
mux1 = 0; muy1 = 0;
theta0 = pi/2;
mux0 = 0; muy0 = 0;

Xspiral_H1 = prtUtilGenerateSpiralCluster(t,f,theta1,mux1,muy1,dx,dy,std);
Xspiral_H0 = prtUtilGenerateSpiralCluster(t,f,theta0,mux0,muy0,dx,dy,std);

X = cat(1,Xspiral_H0,Xspiral_H1);
Y = cat(1,zeros(nSamples,1),ones(nSamples,1));

DataSet = prtDataSetClass(X,Y,'name','prtDataGenSpiral');
