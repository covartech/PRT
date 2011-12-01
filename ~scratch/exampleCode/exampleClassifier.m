%%

clear all;
close all;
clear classes;

DataSet = prtDataGenIris;

DataSet3D = DataSet.setObservations(DataSet.getObservations(:,1:3));
DataSet3DBinary = DataSet3D.setTargets(double(DataSet.getTargets > 2));

plot(DataSet3DBinary);

%%
Dlrt = prtClassDlrt;
Dlrt.k = 10;

Dlrt = Dlrt.train(DataSet3DBinary);
figure;
plot(Dlrt);

%%

yOut = Dlrt.kfolds(DataSet3DBinary,10);
figure;
prtScoreRoc(yOut,DataSet3DBinary);