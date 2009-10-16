function result = prtTestDataSet

result = true;

%% Plot all Labeled data sets

plot(prtDataUnimodal)
drawnow;
plot(prtDataBimodal);
drawnow;
plot(prtDataMary)
drawnow;
plot(prtDataMary2)
drawnow;
plot(prtDataSpiral)
drawnow;
plot(prtDataCircles)
drawnow;
plot(prtDataIris,[1 3 4])
drawnow;
close

%% Other Data Sets

%prtDataProstate
%prtDataSwissRoll
%prtDataSpiral3
%prtDataImageSeg
%prtDataSparseFactors
%prtDataManual

