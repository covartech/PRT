%%
clear all;
close all;

DataSet = prtDataGenIris;

DataSet3D = DataSet.setObservations(DataSet.getObservations(:,1:3));
DataSet3DBinary = DataSet3D.setTargets(double(DataSet.getTargets > 2));

MyAlgo = prtAlgorithm({prtPreProcZmuv,prtClassFld});

%Cross-val over Zmuv and Fld
yOut = MyAlgo.kfolds(DataSet3DBinary,3); 
prtScoreRoc(yOut,DataSet3DBinary);