%% PRT Product Overview
% 

%% PRT Toolbox Overview 
% The PRT is a collection of MATLAB objects and utility functions for
% developing pattern recognition algorithms.  The toolbox provides
% a command-line interface to let you rapidly develop classification
% algorithms and evaluate algorithm performance.
%

%% Installation
%
% Please see: <prtDocInstallation.html Installing the PRT>

%% Using This Guide
%
% If you are new to pattern recognition in general, start out by reading
% <prtDocPatternRecognition.html What is Pattern Recognition?>.  Otherwise,
% if you want to dive right into the PRT, see
% <prtDocGettingStartedExamples.html Some examples of using the PRT>.  For
% installation and documentation questions, please see
% <prtDocInstallation.html Installing the PRT>.

%% PRT Organization
% The PRT provides several hundred MATLAB M-files implementing various
% pattern classification objects and utility functions.  To prevent
% cluttering the MATLAB namespace, all PRT classes and functions begin
% with the string "prt".  Typing "prt", then _tab_ at the MATLAB command
% prompt will bring up a list of all the PRT M-files available (assuming
% the PRT's path has been set properly, see "Installation" below).
%
% To simplify finding the M-file a user is looking for, the PRT implements
% a hierarchical M-file naming scheme, so that all PRT M-files of a
% particular type start with "prtType" where _Type_ is replaced by a
% short mnemonic describing the object or function implemented in the
% M-file. 
%
% The following are some commonly used prt M-file prefixes:
%
% * prtClass* - M-file classes for implementing classification algorithms.
% Examples include prtClassFld, prtClassKnn, and prtClassRvm.
%
% * prtCluster* - M-file classes for implementing clustering algorithms.
% Examples include prtClusterGmm and prtClusterKmeans.
%
% * prtDataGen* - M-file functions for creating standard data sets for
% experimentation and algorithm evaluation.  Examples include
% prtDataGenUnimodal, prtDataGenBimodal, and prtDataGenIris.
%
% * prtDataSet* - M-file classes implementing data storage and bookkeeping
% for collections of data, known as "data sets".  The most commonly used
% prtDataSet classes are prtDataSetClass and prtDataSetRegress.
%
% * prtDecision* - M-file classes implementing decision making.  These are
% commonly used after prtClass objects to turn continuous outputs from
% classifiers into binary or M-ary decisions.  Examples include
% prtDecisionBinaryMinPe and prtDecisionMap.
%
% * prtEval* - M-file functions for evaluating the performance of
% prtAlgorithms.  These are commonly used in prtFeatSel objects to define
% a metric to optimize over.  Examples include prtEvalAuc and
% prtEvalPfAtPd.
%
% * prtKernel* - M-file classes implementing Kernel functions.  Kernels are
% often used in machine learning, and in particular are used in
% prtClassRvm and prtClassSvm.  Example prtKernel objects are
%   prtKernelRbf and prtKernelDc.
%
% * prtPreProc* - M-file classes implementing data transformations often
% used in data pre-processing.  Commonly used objects are prtPreProPca,
% prtPreProcZmuv, and prtPreProcLda.
%
% * prtPlotUtil* - M-file functions used internally to the PRT.  These are
% mostly undocumented and are subject to change.  They should not be
% called directly.
%
% * prtRegress* - M-file classes for implementing regression algorithms.
% Examples include prtRegressLslr and prtRegressRvm.
%
% * prtRv* - M-file classes for implementing random variables.  These
% classes encapsulate PDF and CDF calculation, and maximum likelihood
% parameter estimation.  Examples include prtRvMvn and prtRvUnif.
%
% * prtScore* - M-file functions for evaluating the performance of
% different PRT algorithms.  Examples inclide prtScoreRoc and
% prtScoreConfusionMatrix.
%
% * prtUtil* - M-file functions used internally to the PRT.  These are
% mostly undocumented and are subject to change.  They should not be
% called directly.