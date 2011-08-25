%% Using decision objects in the Pattern Recognition Toolbox
% prtDecision objects are intended to be used in algorithms with, or as
% part of prtClass or prtAlgorithm objects. They change the output of the
% run, crossvalidate and kmeans functions from decision statistics to class
% labels. They also determine the operating point that the decision is made
% at.

%% prtDecision objects as the internalDecider of a prtClass object
% The simplest way to use a prtDecision object is by
% setting the internalDecider property of a prtClass object. For example,
% to set the operating point so that the classifier has the minimum
% probabilty of error:

  ds = prtDataGenBimodal;              % Load a data set
  classifier = prtClassKnn;            % Create a clasifier
  
  % Set the internal decider
  classifier.internalDecider = prtDecisionBinaryMinPe;
  
  result = classifier.kfolds(ds,10);  % K-folds cross validate
  
  pc = prtScorePercentCorrect(result)  % Check the percent correct
  
  %%
  % Other valid binary decision objects are the
  % prtDecisionBinarySpecifiedPf and prtDecisionBinarySpecifiedPd objects,
  % which force the classifier to operate at a specific Pf or Pd.
  
  %% prtDecision objects as part of a prtAlgorithm
  % prtDecisions can also be part of prtAlgorithms, the operation is very
  % similar. For example, the following implements the same classifier as
  % above:
  
  alg = prtClassKnn + prtDecisionBinaryMinPe;  % Create an algorithm object
  result = classifier.kfolds(ds,10);           % K-folds cross validate
  
   pc = prtScorePercentCorrect(result)  % Check the percent correct
   
   %%
   % Note, the percent correct in the two examples may vary slightly due to
   % the inherent randomness of kfolds cross validation
   
   %% M-ary decisions
   % M-ary decisions can be performed using the prtDecisionMap object:
   
   ds = prtDataGenMary;
   classifier = prtClassKnn;
   classifier.internalDecider = prtDecisionMap;
   result = classifier.kfolds(ds,10);            % K-folds cross validate
   
   pc = prtScorePercentCorrect(result)  % Check the percent correct
   
%%   
% All prtDecision objects in the Pattern Recognition Toolbox have the same
% API as discussed above. For a list of all the different functions, and
% links to their individual help entries, <prtDocFunctionList.html#4 A list
% of commonly used functions>
%

   