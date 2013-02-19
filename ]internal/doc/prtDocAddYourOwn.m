%% Developing and testing your own algorithms
% The PRT provides support for incorportating your own algorithms into the
% PRT framework with relative ease. Template classes are provided for
% classifiers, clustering, kernels, outlier removal, pre processing, and
% regression.

%% An Example
% As an example, type
% 
%   prtNewClass
% 
% and enter "prtClassMine" when prompted by the dialog. Press save, and a
% skeleton classifier file will open in the MATLAB editor. This M-file will
% contain instructions for creating your own classification object.
%
% Consider a simple classifier, a generalized likelihood ratio test (GLRT), where
% the two classes are described by multivariate normal random variables.
% Such a classifier would have two parameters, a random variable describing
% each class. So, to construct a classifier object with these parameters, in
% the file prtClassMine, under properties, you would place the following
% definitions:
%
%   rvH0 = prtRvMvn;  % Mean and variance of H0
%   rvH1 = prtRvMvn;  % Mean and variance of H1  
%
% A GLRT classifier must estimate these two random variables. This happens
% during the TRAIN operation. So, for the trainAction code, you would use
% the following code:
%
%   self.rvH0 = mle(self.rvH0, dataSet.getObservationsByClassInd(1));
%   self.rvH1 = mle(self.rvH1, dataSet.getObservationsByClassInd(2));
%        
% The above code would learn the maximal likelhiood estimates of both
% random variables from the training data.
%
% Finally, for a trained classifier, you will need code that outputs a
% decision statistic. So for the runAction, place the following code:
%
%   logLikelihoodH0 = logPdf(self.rvH0, dataSet.getObservations());
%   logLikelihoodH1 = logPdf(self.rvH1, dataSet.getObservations());
%   dataSet = dataSet.setObservations(logLikelihoodH1 - logLikelihoodH0);
%
% Save your M-file and you now have a new prtClass object that can be used
% like any other prtClass object in the toolbox. It will be fully
% compatible with prtAlgorithms and all other features of the PRT.

%% Test suite for the PRT
% A full test suite for the PRT is also provided. You can access it in the
% prtRoot\]internal\test directory. Upon intallation, you might want to
% run the full suite with the command prtTest. If you find yourself
% modifying the provided functions, it is a good idea to run this test from
% time to time to ensure nothing has broken. An abbreviated test,
% prtTestSmoke, is also provided. prtTestSmoke runs a small subset of the
% test suite, and is designed to quickly test the major features of the
% product.