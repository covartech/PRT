%%

clear all;
close all;

DataSet = prtDataIris;

DataSet3D = DataSet.setObservations(DataSet.getObservations(:,1:3));
plot(DataSet3D);


%%
explore(DataSet);

%%
DataSet.starPlot;

%%
x = DataSet.getObservations;
y = DataSet.getTargets;