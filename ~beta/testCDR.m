%
clear all;
close all;
clear classes;

[contextDataSet,classificationDataSet] = prtDataGenContextDependent;
cdR = prtBlockContextDependentRvm;

cdR = cdR.train(contextDataSet,classificationDataSet);
yOut = cdR.run(contextDataSet,classificationDataSet);