clear classes;

% Copyright (c) 2014 CoVar Applied Technologies
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.
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
