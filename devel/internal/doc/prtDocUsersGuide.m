%% The Pattern Recognition Toolbox Users Guide
%
% The Pattern Recognition Toolbox Users Guide begins with an introduction
% to the various dataset objects that are necessary to perform
% classification or regression. 
%
% * <matlab:web(fullfile(prtRoot,'doc','prtDocDataSet.html'),'-helpbrowser'); Pattern Recognition Toolbox DataSets>
%
% The next topic is the Pattern Recognition Toolbox Engine, which discusses
% the syntax for prtAction objects. This syntax is common for most of the
% functionality in the Pattern Recognition Toolbox.
%
% * <matlab:web(fullfile(prtRoot,'doc','prtDocEngine.html'),'-helpbrowser'); Pattern Recognition Toolbox Engine>
%
% Following, Classifiers and Pre-processing techniques are presented. 
%
% * <matlab:web(fullfile(prtRoot,'doc','prtDocClass.html'),'-helpbrowser');  Pattern Recognition Toolbox Classification Objects>
% * <matlab:web(fullfile(prtRoot,'doc','prtDocPreProc.html'),'-helpbrowser'); Pattern Recognition Toolbox Preprocessing Objects>
%
% Algorithm objects allow multiple prtActions to be connected together,
% and use the same training, running and evaluation syntax as a single
% prtAction.
%
% * <matlab:web(fullfile(prtRoot,'doc','prtDocAlgorithm.html'),'-helpbrowser'); Pattern Recognition Toolbox Algorithm Objects>
%
%  Regression is similar to classification, but maps observations to a
%  continuum of numbers, as opposed to a discrete set of class labels.
%
% * <matlab:web(fullfile(prtRoot,'doc','prtDocRegress.html'),'-helpbrowser'); Pattern Recognition Toolbox Regression Objects>
%
%  Clustering is also closely related to classification, however, in
%  clustering, class labels are not used during training.
%
% * <matlab:web(fullfile(prtRoot,'doc','prtDocCluster.html'),'-helpbrowser'); Pattern Recognition Toolbox Clustering Objects>
%
%  Scoring and evaulation provide methods to analyze the results of your
%  classification, regression or clustering. Scoring functions work on
%  prtDataSets, while evaluation functions work on prtAction objects.
%
% * <matlab:web(fullfile(prtRoot,'doc','prtDocScore.html'),'-helpbrowser'); Pattern Recognition Toolbox Scoring functions>
% * <matlab:web(fullfile(prtRoot,'doc','prtDocEval.html'),'-helpbrowser'); Pattern Recognition Toolbox Evaluation functions>
%
%  Decision objects take the outputs of a prtAction object and make
%  decisions according to particular criteria, such as the minimum probability
%  of error. 
% 
% * <matlab:web(fullfile(prtRoot,'doc','prtDocDecision.html'),'-helpbrowser'); Pattern Recognition Toolbox Decision Objects>
%
%  Kernels are useful in many nonlinear classification and regression
%  problems. The Pattern Recognition Toolbox provides a suite of common
%  kernels to be used in conjunction with prtClass and prtRegress objects.
%
% * <matlab:web(fullfile(prtRoot,'doc','prtDocKernel.html'),'-helpbrowser'); Pattern Recognition Toolbox Kernel Objects>
%
%  The Pattern Recognition Toolbox also provides a set of distance
%  functions, such as Euclidean, Mahalonobis and other distance metrics, to
%  be used in conjunction with prtActions.
%
% * <matlab:web(fullfile(prtRoot,'doc','prtDocDistance.html'),'-helpbrowser'); Pattern Recognition Toolbox Distance Functions>
%
%  Random variables often form important components of prtActions, and a
%  set of random variable objects is provided.
%
% * <matlab:web(fullfile(prtRoot,'doc','prtDocRv.html'),'-helpbrowser'); Pattern Recognition Toolbox Random Variable Objects>
%
%  Feature selection is a technique that helps select the features that
%  have the greatest effect on the performance of prtActions. 
%
% * <matlab:web(fullfile(prtRoot,'doc','prtDocFeatSel.html'),'-helpbrowser'); Pattern Recognition Toolbox Feature Selection Objects>
%
%  Often, data collected from real world applications may contain outliers
%  that are not relevant, and that may skew results. The Pattern
%  Recognition Toolbox provides a set of outlier removal objects.
%
% * <matlab:web(fullfile(prtRoot,'doc','prtDocOutlierRemoval.html'),'-helpbrowser'); Pattern Recognition Toolbox Outlier Removal Objects>
%
% Finally, the Pattern Recognition Toolbox provides a set of data
% generation functions, which can be useful for creating example or
% prototying.
%
% * <matlab:web(fullfile(prtRoot,'doc','prtDocDataGen.html'),'-helpbrowser'); Pattern Recognition Toolbox Data Generation Functions>
%
% Copyright 2011 New Folder Consulting L.L.C.
