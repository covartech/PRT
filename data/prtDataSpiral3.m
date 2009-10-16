function DataSet = prtDataSpiral3
% This is a spiral data set usex in Ueda et al. 2000
% It has a 1 dimensional manifold in 3 dimensions with noise

nSamples = 800;
t = rand(nSamples,1)*4*pi;
t = sort(t);

X = [(13-0.5*t).*cos(t) -(13-0.5*t).*sin(t) t] + mvnrnd(zeros(3,1),0.5*eye(3),nSamples);
Y = t;

DataSet = prtDataSet(X,Y,'dataSetName','prtDataSpiral3');