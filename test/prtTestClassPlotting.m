function result = prtTestClassPlotting

result = true;
try
    dsbinary = prtdatagenbimodal;
    dsmary = prtdatageniris;
    dsmary = dsmary.retainfeatures(1:2);
    
    %% test binary plot classifier; no decision
    binaryclassifier = prtclassadaboost;
    binaryclassifier = binaryclassifier.train(dsbinary);
    binaryclassifier.plot;
    
    %% test binary plot classifier; with decision
    clc;
    binaryclassifier = prtclassadaboost;
    binaryclassifier.internaldecider = prtdecisionbinaryminpe;
    binaryclassifier = binaryclassifier.train(dsbinary);
    binaryclassifier.plot;
    
    %% m-ary classifier; no decision
    maryclassifier = prtclassknn;
    maryclassifier = maryclassifier.train(dsmary);
    maryclassifier.plot;
    
    %% m-ary classifier; with decision
    clc;
    close all;
    maryclassifier = prtclassknn;
    maryclassifier.internaldecider = prtdecisionmap;
    maryclassifier = maryclassifier.train(dsmary);
    maryclassifier.plot;
    
    %% m-ary-binary classifier; no decision
    close all;
    marybinaryclassifier = prtclassbinarytomaryonevsall('classifiers',prtclasslogisticdiscriminant);
    marybinaryclassifier = marybinaryclassifier.train(dsmary);
    marybinaryclassifier.plot;
    
    %% m-ary-binary classifier; with decision
    close all;
    marybinaryclassifier = prtclassbinarytomaryonevsall('classifiers',prtclasslogisticdiscriminant);
    marybinaryclassifier.internaldecider = prtdecisionmap;
    marybinaryclassifier = marybinaryclassifier.train(dsmary);
    marybinaryclassifier.plot;
    
    %% clustering - m-ary data
    close all;
    clusterer = prtclusterkmeans;
    clusterer = clusterer.train(dsmary);
    clusterer.plot;
    
    %% clustering with decision
    close all;
    clusterer = prtclusterkmeans;
    clusterer.internaldecider = prtdecisionmap;
    clusterer = clusterer.train(dsmary);
    clusterer.plot;
    
    %% clustering - m-ary data
    close all;
    clusterer = prtclusterkmeans;
    clusterer.nclusters = 2;
    clusterer = clusterer.train(dsbinary);
    clusterer.plot;
    
    %% clustering with decision
    close all;
    clusterer = prtclusterkmeans;
    clusterer.nclusters = 2;
    clusterer.internaldecider = prtdecisionmap;
    clusterer = clusterer.train(dsbinary);
    clusterer.plot;
catch
    result = false;
end