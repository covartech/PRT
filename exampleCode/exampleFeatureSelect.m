%%
clear all;
close all;
clear classes;

DataSet = prtDataIris;
DataSetBinary = DataSet.setTargets(double(DataSet.getTargets > 2));

Sfs = prtFeatSelSfs;
Sfs = Sfs.train(DataSetBinary);

DataSetSfs = Sfs.run(DataSetBinary);
plot(DataSetSfs);