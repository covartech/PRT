%% prtTestDataSetStandard
clear all;
close all;
clear classes;

nSamples = 100;
nFeatures = 10;
nTargetDims = 5;
x = randn(nSamples,nFeatures);
y = rand(nSamples,nTargetDims) > .5;

%% Get methods:
DS = prtDataSetClass(x,y);

assert(isequal(DS.getFeatures,x),'getFeatures');
assert(isequal(DS.getFeatures([3,5]),x(:,[3,5])),'getFeatures');

assert(isequal(DS.getObservations,x),'getObservations');
assert(isequal(DS.getObservations(:,[3,5]),x(:,[3,5])),'getObservations');
assert(isequal(DS.getObservations(9:2:12,[3,5]),x(9:2:12,[3,5])),'getObservations');

assert(isequal(DS.getTargets,y),'getTargets');
assert(isequal(DS.getTargets(:,[3,5]),y(:,[3,5])),'getTargets');
assert(isequal(DS.getTargets(9:2:12,[3,5]),y(9:2:12,[3,5])),'getTargets');

[xx,yy] = DS.getObservationsAndTargets(1:3:12,1:2:5);
assert(isequal(xx,x(1:3:12,1:2:5)) && isequal(yy,y(1:3:12,:)),'getObservationsAndTargets');
[xx,yy] = DS.getObservationsAndTargets(1:3:12,1:2:5,1:3);
assert(isequal(xx,x(1:3:12,1:2:5)) && isequal(yy,y(1:3:12,1:3)),'getObservationsAndTargets');

%% Set observations methods:

xxTemp = randn(10,10);
xxTempX = x;
xxTempX(1:2:20,:) = xxTemp;
DStemp = DS;
DStemp = DStemp.setObservations(xxTemp,1:2:20);
assert(isequal(xxTempX,DStemp.getObservations),'getObservations');
DStemp = DStemp.setObservations(xxTemp,1:2:20,:);
assert(isequal(xxTempX,DStemp.getObservations),'getObservations');

%% Set targets methods:

yyTemp = rand(10,5) > .5;
yyTempY = y;
yyTempY(1:2:20,:) = yyTemp;
DStemp = DS;
DStemp = DStemp.setTargets(yyTemp,1:2:20);
assert(isequal(yyTempY,DStemp.getTargets),'getTargets');
DStemp = DStemp.setTargets(yyTemp,1:2:20,:);
assert(isequal(yyTempY,DStemp.getTargets),'getTargets');

%% Set targets methods:

yyTemp = rand(10,5) > .5;
yyTempY = y;
yyTempY(1:2:20,:) = yyTemp;
DStemp = DS;
DStemp = DStemp.setTargets(yyTemp,1:2:20);
assert(isequal(yyTempY,DStemp.getTargets),'getTargets');
DStemp = DStemp.setTargets(yyTemp,1:2:20,:);
assert(isequal(yyTempY,DStemp.getTargets),'getTargets');

%%
obsNames = {'obs1','obs2','obs3','obs4'}';
DSlocal = DS;

DSlocal = DSlocal.setObservationNames(obsNames,1:4);

assert(isequal(DSlocal.getObservationNames([1 3 4]),obsNames([1 3 4])),'setObservationNames');
DSlocal = DSlocal.catObservations(DSlocal);
assert(isequal(DSlocal.getObservationNames([101 103 104]),obsNames([1 3 4])),'setObservationNames');
DSlocal = DSlocal.removeObservations(100:103);
assert(isequal(DSlocal.getObservationNames([100]),obsNames([4])),'setObservationNames');

%%
featNames = {'feat1','feat2','feat3','feat4'}';
DSlocal = DS;

DSlocal = DSlocal.setFeatureNames(featNames,1:4);

assert(isequal(DSlocal.getFeatureNames([1 3 4]),featNames([1 3 4])),'setFeatureNames');
DSlocal = DSlocal.catFeatures(DSlocal);
assert(isequal(DSlocal.getFeatureNames([11 13 14]),featNames([1 3 4])),'setFeatureNames');
DSlocal = DSlocal.removeFeatures(1:2:20);
assert(isequal(DSlocal.getFeatureNames(1:3),{'feat2';'feat4';'Feature 3'}),'setFeatureNames');
