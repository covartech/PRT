function DataSet = prtDataGenSpiral3
% prtDataGenSpiral3 - Generate a 3-D spiral data set from a 1-D manifold
%
% dataSet = prtDataGenSpiral3; Generates the spiral data set used in Ueda 
% et al. 2000.  It consists of a 1 dimensional manifold in 3 dimensions 
% with additive noise.

nSamples = 800;
t = rand(nSamples,1)*4*pi;
t = sort(t);

X = [(13-0.5*t).*cos(t) -(13-0.5*t).*sin(t) t] + mvnrnd(zeros(3,1),0.5*eye(3),nSamples);
Y = t;

DataSet = prtDataSetRegress(X,Y,'name','prtDataGenSpiral3');