function result = prtTestDataSet

result = true;

%% Plot all Labeled data sets

plot(prtDataGenUnimodal)
drawnow;
plot(prtDataGenBimodal);
drawnow;
plot(prtDataGenMary)
drawnow;
plot(prtDataGenMary2)
drawnow;
plot(prtDataGenSpiral)
drawnow;
plot(prtDataGenCircles)
drawnow;
plot(prtDataGenIris,[1 3 4])
drawnow;
close

%% Other Data Sets

prtDataGenProstate;
prtDataGenSwissRoll;
prtDataGenSpiral3;
prtDataGenImageSeg;
prtDataGenSparseFactors;
prtDataGenManual;
prtDataGenFeatureSelection;
prtDataGenOldFaithful;
prtDataGenNoisySync;
prtDataGenXor;

%% Test Catting of prtDataSetInMemory
DS = prtDataGenUnimodal;
UDS = prtDataSetClass(DS.getObservations);
DS = prtDataGenSpiral;
UDS2 = prtDataSetClass(DS.getObservations);
CatDS = joinObservations(UDS,UDS2);
CatDS = joinFeatures(UDS,UDS2);

%% Test Catting of prtDataSetLabeled
DS = prtDataGenUnimodal;
DS2 = prtDataGenSpiral;
CatDS = joinObservations(DS, DS2);
CatDS = joinFeatures(DS, DS2);

DS3 = prtDataGenMary2;

CatDS = joinFeatures(DS, DS2);

