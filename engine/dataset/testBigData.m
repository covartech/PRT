clear classes;
clc;

h = prtDataHandlerMatFiles('fileList','Y:\swap\prtBigDataTest');
ds = prtDataSetClassBig('dataHandler',h);

mapReduceMean = prtMapReduceMean;
out = ds.mapReduce(mapReduceMean);

%%
[out2,maps] = mapReduceMean.run(ds);

%%
[expectedTime,elapsedTime] = mapReduceMean.estimateTime(ds,10);
tic;
[out2,maps] = mapReduceMean.run(ds);
toc;

%%
mr = prtMapReduceStd;
mr.run(ds);

%%
clear classes;
h = prtDataHandlerMatFiles('fileList','Y:\swap\prtBigDataTestBimodal');
ds = prtDataSetClassBig('dataHandler',h);
summ = ds.summarize;

%%

%%
kmeans = prtPreProcKmeans('nClusters',4);
kmeans = kmeans.trainBig(ds);

%%
dsKmeans = kmeans.runBig(ds);

%%
class = prtClassLogisticDiscriminant;
class = class.trainBig(dsKmeans);

yOut = runBig(class,dsKmeans);

%%
algo = prtPreProcKmeans('nClusters',4) + prtPreProcZmuv + prtClassLogisticDiscriminant;
algo = algo.trainBig(ds);
yOut = algo.runBig(ds);
