%% prtClassBagging
% 
% prtClassBagging implements a bootstrap aggregation (Bagging) method of
% generating an ensemble of classification algorithms.  The motivation
% behind bagging is to use multiple bagging samples from the training data
% set to generate classification algorithms and utilize the average over
% these individual classification algorithms to provide smoother and more
% robust decision contours.  Bagging can be seen as a meta algorithm for 
% smoothing over the responses of multiple individual learning algorithms.
%
% The interested reader is encouraged to investigate the wikipedia page
% (http://en.wikipedia.org/wiki/Bootstrap_aggregating) as well as the 
% references linked from that page for more information on Bagging.
%
% We can build an Bagging classifier the same way we build other
% classifiers. 
%

ds = prtDataGenUnimodal(50,[0 0],[3 3],eye(2),eye(2)*3);

naiveClassifier = prtClassFld;
naiveClassifier = naiveClassifier.train(ds);

classifier = prtClassBagging;
classifier = classifier.train(ds);

subplot(2,1,1); plot(classifier); title('Bagging FLD');
subplot(2,1,2); plot(naiveClassifier); title('Single FLD');

%%
%  The default Bagging classifier makes use of a Fisher linear
%  discriminant classifier as the base classifier, but we can change the
%  behavior of our bagging classifier to make use of different
%  prtClassifiers also:

ds = prtDataGenUnimodal;
classifier = prtClassBagging;
classifier.baseClassifier = prtClassCap;
classifier = classifier.train(ds);
plot(classifier);

%% Notes
%
% Note that because Bagging relies on bootstrapping, results from multiple
% Bagging classifiers trained on the same data will not generate exactly 
% the same classifiers each time.
%

%% General
% As witl all prtClass* objects, the methods train, run, kfolds, and 
% crossValidate are also available for prtClassBagging objects.