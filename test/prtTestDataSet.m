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

%% Test Catting of prtDataSetInMemory
DS = prtDataUnimodal;
UDS = prtDataSet(DS.getObservations);
DS = prtDataSpiral;
UDS2 = prtDataSet(DS.getObservations);
CatDS = vertcat(UDS,UDS2);
CatDS = horzcat(UDS,UDS2);

%% Test Catting of prtDataSetLabeled
DS = prtDataUnimodal;
DS2 = prtDataSpiral;
CatDS = vertcat(DS, DS2);
CatDS = horzcat(DS, DS2);

DS3 = prtDataMary2;

CatDS = horzcat(DS, DS3);

