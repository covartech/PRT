%% prtClassAdaBoost
% 
% prtClassAdaBoost implements the AdaBoost algorithm for pattern
% recognition.  AdaBoost is a meta algorithm for combining multiple weak
% learners into a single strong algorithm.  There has been a good deal of
% work done on why AdaBoost works so well.  The interested reader is
% encouraged to investigate the wikipedia page
% (http://en.wikipedia.org/wiki/AdaBoost) as well as the references linked
% from that page.
%
% We can build an AdaBoost classifier the same way we build other
% classifiers. 
%

ds = prtDataGenUnimodal;
classifier = prtClassAdaBoost;
classifier = classifier.train(ds);
plot(classifier);

%%
%  The default AdaBoost classifier makes use of a Fisher linear
%  discriminant classifier as the base classifier, so it's not surprising
%  that AdaBoost can discriminate between two unimodal distributions.
%  However AdaBoost can generate much more complicated decision surfaces
%  also.  For example:

ds = prtDataGenBimodal;
classifier = prtClassAdaBoost;
classifier = classifier.train(ds);
plot(classifier);

%% Changing the Base Classifier
%
% Of course, there's no rule that AdaBoost has to make use of the FLD
% classifier; we can change the default behavior of AdaBoost to use any
% other classifier (but simpler, naive classifiers tend to work best).

ds = prtDataGenBimodal;
classifier = prtClassAdaBoost;
classifier.baseClassifier = prtClassCap;
classifier = classifier.train(ds);
plot(classifier);

%% Changing the Number of Classifiers to Build
%
% By default, AdaBoost makes a collection of 30 classifiers for processing.
% We can change this number and explore the differences in the
% classification boundaries also:

ds = prtDataGenBimodal;
classifier1 = prtClassAdaBoost('nBoosts',3);
classifier2 = prtClassAdaBoost('nBoosts',10);
classifier3 = prtClassAdaBoost('nBoosts',30);
classifier4 = prtClassAdaBoost('nBoosts',100);

classifier1 = classifier1.train(ds);
classifier2 = classifier2.train(ds);
classifier3 = classifier3.train(ds);
classifier4 = classifier4.train(ds);

subplot(2,2,1); classifier1.plot; title('3 Classifiers');
subplot(2,2,2); classifier2.plot; title('10 Classifiers');
subplot(2,2,3); classifier3.plot; title('30 Classifiers');
subplot(2,2,4); classifier4.plot; title('100 Classifiers');

%% Notes
%
% Note that because AdaBoost relies on bootstrapping, results from multiple
% AdaBoost classifiers trained on the same data will not generate exactly 
% the same classifiers each time.
%

%% General
% As witl all prtClass* objects, the methods train, run, kfolds, and 
% crossValidate are also available for prtClassAdaBoost objects.