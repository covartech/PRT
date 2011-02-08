%% prtClassRvm and Subplasses
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

TrainingDataSet = prtDataGenUnimodal;

classifier{1} = prtClassRvm('learningVerbose',true,'learningPlot',10);
classifier{1} = classifier{1}.train(TrainingDataSet);

classifier{2} = prtClassRvmFigueiredo('learningVerbose',true,'learningPlot',10);
classifier{2} = classifier{2}.train(TrainingDataSet);

classifier{3} = prtClassRvmSequential('learningVerbose',true,'learningPlot',10);
classifier{3} = classifier{3}.train(TrainingDataSet);

close all

subplot(2,2,1)
plot(classifier{1})
subplot(2,2,2)
plot(classifier{2})
subplot(2,2,3)
plot(classifier{3})