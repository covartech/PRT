function result = prtTestClassPlotting

result = true;
try
    dsbinary = prtDataGenBimodal;
    dsmary = prtDataGenIris;
    dsmary = dsmary.retainFeatures(1:2);
    
    %% test binary plot classifier; no decision
    binaryclassifier = prtClassAdaBoost;
    binaryclassifier = binaryclassifier.train(dsbinary);
    binaryclassifier.plot; drawnow; pause(0.1);
    
    %% test binary plot classifier; with decision
    
    binaryclassifier = prtClassAdaBoost;
    binaryclassifier.internalDecider = prtDecisionBinaryMinPe;
    binaryclassifier = binaryclassifier.train(dsbinary);
    binaryclassifier.plot; drawnow; pause(0.1);
    
    %% m-ary classifier; no decision
    maryclassifier = prtClassKnn;
    maryclassifier = maryclassifier.train(dsmary);
    maryclassifier.plot; drawnow; pause(0.1);
    
    %% m-ary classifier; with decision
    
    close all;
    maryclassifier = prtClassKnn;
    maryclassifier.internalDecider = prtDecisionMap;
    maryclassifier = maryclassifier.train(dsmary);
    maryclassifier.plot; drawnow; pause(0.1);
    
    %% m-ary-binary classifier; no decision
    close all;
    marybinaryclassifier = prtclassbinarytomaryonevsall('baseClassifier',prtclasslogisticdiscriminant);
    marybinaryclassifier = marybinaryclassifier.train(dsmary);
    marybinaryclassifier.plot; drawnow; pause(0.1);
    
    %% m-ary-binary classifier; with decision
    close all;
    marybinaryclassifier = prtClassBinaryToMaryOneVsAll('baseClassifier',prtclasslogisticdiscriminant);
    marybinaryclassifier.internalDecider = prtDecisionMap;
    marybinaryclassifier = marybinaryclassifier.train(dsmary);
    marybinaryclassifier.plot; drawnow; pause(0.1);
    
    %% clustering - m-ary data
    close all;
    clusterer = prtClusterKmeans;
    clusterer = clusterer.train(dsmary);
    clusterer.plot; drawnow; pause(0.1);
    
    %% clustering with decision
    close all;
    clusterer = prtClusterKmeans;
    clusterer.internalDecider = prtDecisionMap;
    clusterer = clusterer.train(dsmary);
    clusterer.plot; drawnow; pause(0.1);
    
    %% clustering - m-ary data
    close all;
    clusterer = prtClusterKmeans;
    clusterer.nClusters = 2;
    clusterer = clusterer.train(dsbinary);
    clusterer.plot; drawnow; pause(0.1);
    
    %% clustering with decision
    close all;
    clusterer = prtClusterKmeans;
    clusterer.nClusters = 2;
    clusterer.internalDecider = prtDecisionMap;
    clusterer = clusterer.train(dsbinary);
    clusterer.plot; drawnow; pause(0.1);
catch
    result = false;
end