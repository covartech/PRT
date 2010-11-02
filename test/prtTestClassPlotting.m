function prtTestClassPlotting

dsBinary = prtDataGenBimodal;
dsMary = prtDataGenIris;
dsMary = dsMary.retainFeatures(1:2);

%% Test binary plot classifier; no decision
binaryClassifier = prtClassAdaBoost;
binaryClassifier = binaryClassifier.train(dsBinary);
binaryClassifier.plot;

%% Test binary plot classifier; with decision
clc;
binaryClassifier = prtClassAdaBoost;
binaryClassifier.internalDecider = prtDecisionBinaryMinPe;
binaryClassifier = binaryClassifier.train(dsBinary);
binaryClassifier.plot;

%% M-ary classifier; no decision
maryClassifier = prtClassKnn;
maryClassifier = maryClassifier.train(dsMary);
maryClassifier.plot;

%% M-ary classifier; with decision
clc;
close all;
maryClassifier = prtClassKnn;
maryClassifier.internalDecider = prtDecisionMap;
maryClassifier = maryClassifier.train(dsMary);
maryClassifier.plot;

%% M-ary-binary classifier; no decision
close all;
maryBinaryClassifier = prtClassBinaryToMaryOneVsAll('Classifiers',prtClassLogisticDiscriminant);
maryBinaryClassifier = maryBinaryClassifier.train(dsMary);
maryBinaryClassifier.plot;

%% M-ary-binary classifier; with decision
close all;
maryBinaryClassifier = prtClassBinaryToMaryOneVsAll('Classifiers',prtClassLogisticDiscriminant);
maryBinaryClassifier.internalDecider = prtDecisionMap;
maryBinaryClassifier = maryBinaryClassifier.train(dsMary);
maryBinaryClassifier.plot;

%% Clustering - M-ary data
close all;
clusterer = prtClusterKmeans;
clusterer = clusterer.train(dsMary);
clusterer.plot;

%% Clustering with decision
close all;
clusterer = prtClusterKmeans;
clusterer.internalDecider = prtDecisionMap;
clusterer = clusterer.train(dsMary);
clusterer.plot;

%% Clustering - M-ary data
close all;
clusterer = prtClusterKmeans;
clusterer.nClusters = 2;
clusterer = clusterer.train(dsBinary);
clusterer.plot;

%% Clustering with decision
close all;
clusterer = prtClusterKmeans;
clusterer.nClusters = 2;
clusterer.internalDecider = prtDecisionMap;
clusterer = clusterer.train(dsBinary);
clusterer.plot;