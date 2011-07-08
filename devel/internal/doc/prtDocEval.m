%% Evaluating classifiers
% While prtScore functions operate on data sets, prtEval functions operate
% on classifiers and data sets. The other key difference is that they
% return scalars rather than vectors. They are useful for finding a
% particular performance measure of a classifier. They are also very useful
% for optimizing classifiers and performing feature reduction.
%

%% Using prtEval functions directly with prtActions
% First, consider a simple example, evaluating the percent correct of a
% classifier:

dataSet = prtDataGenSpiral;
classifier = prtClassDlrt;
pc =  prtEvalPercentCorrect(classifier, dataSet)

%%
% Note, in the above example, the internal decider was not set, so the
% minimum probability of error was used as the decision rule. By setting
% the internal decider to a prtDecision object, a different probability
% correct will be obtained:

% Set the decider so that the object has at least a probility of false
% alarm of .1 or less.
classifier.internalDecider = prtDecisionBinarySpecifiedPf('pf',.1);
pc =  prtEvalPercentCorrect(classifier, dataSet)

%% Evaluating classifier in conjunction with optimizing performance
% Another important use of the prtEval functions is to optimize performance
% of a prtAction. Continuing the following example, use the optimize
% function to select the best performance of the classifier for a range of
% k values:p

kVec = 1:20;
[optClassifier, pc] = classifier.optimize(dataSet, @(class,ds)prtEvalPercentCorrect(class,ds,10), 'k',kVec);
plot(kVec, pc); title('Number of neighbors versus percent correct'); xlabel('Number of neighbors'); ylabel('Percent Correct')

%% 
% The above example illustrates that increasing the number of neighbors
% improves the performance of the classifier for this data set, but only to
% a point, after which performance begins to decline.
%
% All evaluation functions in the Pattern Recognition Toolbox have the same
% API as discussed above. The difference is in the performance metric to be
% evaluated. For a list of all the different functions, and links to their
% individual help entries, <prtDocFunctionList.html A list of commonly used
% functions>
%
% For more information on the use of prtEval functions in conjunction with
% feature selection techniques, see <prtDocFeatSel.html Feature Selection>