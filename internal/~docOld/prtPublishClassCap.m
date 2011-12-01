%% prtClassCap
% 
% prtClassCap implements a basic central-axis-projection classifier.  A CAP
% classifier attempts to discriminate between classes by projecting test
% points onto the line separating the means of the distributions under each
% hypothesis, and determining a threshold along that line such that if the
% value of the projection > threshold, the output is of class 1.
%
% CAP classifiers are "weak" classification algorithms in the sense that
% they are not able to learn complicated decision surfaces, but they are
% used in several meta-algorithms which attempt to build string classifiers
% from ensembles of weaker classifiers (e.g. prtClassAdaBoost, 
% prtClassBagging, prtClassTreeBaggerCap, etc.)
%
% An introduction and explanation of CAP classifiers can be found in the
% paper on Random Forests: 
%
%    Breiman, Leo (2001). "Random Forests". Machine Learning 45 (1):
%    5–32.
%
% We can build a CAP  classifier the same way we build other
% classifiers. 
%

ds = prtDataGenUnimodal;
classifier = prtClassCap;
classifier = classifier.train(ds);
plot(classifier); title('CAP Classifier');

%%
% Note that CAP classifiers fail to discriminate between overlapping
% multi-modal distributions:

ds = prtDataGenBimodal;
classifier = prtClassCap;
classifier = classifier.train(ds);

plot(classifier); title('CAP Classifier');

%%
% Scoring the classifier shows how poor the performance is:

%Note, since prtClassCap performs automatic decision making, this is valid; 
%for most classifiers explicit decision actions must be specified to enable
%confusion matrix scoring, see the help entry for prtClass for more
%information.

yOut = classifier.kfolds(ds);
prtScoreConfusionMatrix(yOut,ds);  
title('CAP Confusion Matrix on Multi-Modal Data');

%% General
% As witl all prtClass* objects, the methods train, run, kfolds, and 
% crossValidate are also available for prtClassCap objects.