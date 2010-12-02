%% prtClassDlrt
% 
% prtClassDlrt implements a distance-likelihood ratio test classifier.  A
% DLRT classifier is similar in many ways to a two-class KNN classifier
% except that instead of outputing the number of votes each class receives,
% a DLRT attempts to estimate the a-posteriori class probabilities of a new
% data point.
%
% A paper on the goals and results from DLRT classifiers can be found here:
%
%    Remus, J.J. et al., "Comparison of a distance-based likelihood ratio 
%    test and k-nearest neighbor classification methods" Machine Learning 
%    for Signal Processing, 2008. MLSP 2008. IEEE Workshop on, October,
%    2008.
%
% We can build a DLRT  classifier the same way we build other
% classifiers. 
%

ds = prtDataGenUnimodal;
classifier = prtClassDlrt;
classifier = classifier.train(ds);
plot(classifier); title('DLRT Classifier');

%%
% Because of their non-parametric nature, DLRT classifiers can be used in
% multi-modal situations, much like KNN classification approaches:

ds = prtDataGenBimodal;
classifier = prtClassDlrt;
classifier = classifier.train(ds);

plot(classifier); title('DLRT Classifier');

%% Parameters
% There are two main parameters of interest in a prtClassDlrt - k, the
% number of neighbors, and distanceFunction which controls how distances
% are calculated.
%
% Changing k changes the smoothness of the classification boundaries:

ds = prtDataGenBimodal;
classifier1 = prtClassDlrt('k',1);
classifier2 = prtClassDlrt('k',3);
classifier3 = prtClassDlrt('k',11);
classifier4 = prtClassDlrt('k',21);

classifier1 = train(classifier1,ds);
classifier2 = train(classifier2,ds);
classifier3 = train(classifier3,ds);
classifier4 = train(classifier4,ds);

subplot(2,2,1); classifier1.plot;
subplot(2,2,2); classifier2.plot;
subplot(2,2,3); classifier3.plot;
subplot(2,2,4); classifier4.plot;

%% 
% Similarly, changing the distanceFunction to other valid prtDistance
% functions changes the shape of the boundaries

ds = prtDataGenBimodal;
classifier1 = prtClassDlrt('distanceFunction',@(x,y)prtDistanceEuclidean(x,y)); %the default
classifier2 = prtClassDlrt('distanceFunction',@(x,y)prtDistanceCityBlock(x,y)); %City-block distnace
classifier3 = prtClassDlrt('distanceFunction',@(x,y)prtDistanceLnorm(x,y,0));   %L-0 norm
classifier4 = prtClassDlrt('distanceFunction',@(x,y)prtDistanceLnorm(x,y,inf)); %L-inf norm

classifier1 = train(classifier1,ds);
classifier2 = train(classifier2,ds);
classifier3 = train(classifier3,ds);
classifier4 = train(classifier4,ds);

subplot(2,2,1); classifier1.plot;
subplot(2,2,2); classifier2.plot;
subplot(2,2,3); classifier3.plot;
subplot(2,2,4); classifier4.plot;

%% General
% As witl all prtClass* objects, the methods train, run, kfolds, and 
% crossValidate are also available for prtClassDlrt objects.