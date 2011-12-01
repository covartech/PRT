%% Feature selection in the Pattern Recognition Toolbox
% 
% Feature selection is a technique that is used to determine which features
% of a data set are most relevant to performing classification. In general,
% for a fixed size training set, incorporating more features in classifier
% training can lead to declining performance due to the curse of
% dimensionality.  Therefore, it is often desirable to reduce
% the amount of features used to perform classification to the smallest
% amount possible that still gives the desired performance. prtFeatSel
% objects provide a way to select features based on a performance criteria.

%% Exhaustive feature selection
%
%  Exhaustive feature selection works by exhaustively comparing all
%  possible combinations of features that could be selected. The number of
%  features to be selected must be determined beforehand. The feature
%  selection algorithm will then evaluate the classifier with all
%  combinations of features and select the set that gives the best
%  performance. The classifier performance is determined by specifying a
%  prtEval object. Note that the computational complexity of exhaustive
%  feature selection grows very rapidly, so that for even moderately sized
%  data sets, exhaustive feature selection is impractical.  The following
%  example illustrates exhaustive feature selection:

% Generate a data set, this data set has a redundant feature intentionally
% inserted for example purposes.
dataSet = prtDataGenFeatureSelection;

featSel = prtFeatSelExhaustive;   % Create a feature selction object
featSel.nFeatures = 3;            % Select three features of the data

 % The classification will be done using a prtClassGlrt object.
classifier = prtClassGlrt;       

%   Change the evaluation metric to prtScoreAuc, the area under the
%   receiver operating curve.
featSel.evaluationMetric = @(DS)prtEvalAuc(classifier, DS);

featSel = featSel.train(dataSet);  % Train the feature selection object
outDataSet = featSel.run(dataSet); % Run the classifier on the data set 
                                   % using only the selected features
                                   
%%
% The above example illustrates several important things about feature
% selection. First, the clasification algorithm must be specified, as is
% done by passing a prtClassGlrt object to the prtEval function. You can
% instantiate and configure the prtClass object just like any other
% prtClass object. Second, the evaluation is done by a prtEval object,
% which takes the classifier and data set, and evaluates it in terms of a
% given performance metric.
%
% By calling the train method on the prtFeatSel object, all possible
% combinations of 3 features are evaluated, and the set resulting in the
% best performance, is selected. The selected features are:

featSel.selectedFeatures

%%
% Finally, calling the run function on the dataset, runs the prtGlrt
% classifier object, but only using the features that were found during
% training, and outputs the result.

%% Sequential forward selection
% Exhaustive feature selection can take a considerable amount of time to
% train, particularly if the number of features is large. Sequential
% feature selection can potentially resolve this problem while reducing the
% amount of training time. Sequential forward selection starts by selecting
% one feature by and evaluating the classifier on each feature
% individually. The feature that gives the best performance is then
% selected. If more than one feature is requested, the feature selection
% object will then repeat this, adding features, and selecting the one that
% most improves performance, until the desired number of features has been
% met. For example:

% Create a sequential forward selection object
featSel = prtFeatSelSfs;

% For fair comparision, leave the evaluation and classifier the same:
featSel.evaluationMetric = @(DS)prtEvalAuc(classifier, DS);

featSel = featSel.train(dataSet);  % Train the feature selection object
featSel.selectedFeatures

%%
% Observe that the selected features are [3 1 7]. Notice that they are the
% same features as found in the exhaustive feature selection, but in
% different order. This is because feature 3 contributes the most to the
% performance metric, follwed by feature 1, then feature 7. Note that it is
% not guaranteed that sequential forward selection will select the same
% features as exhaustive selection, it is merely a coincidence in this
% case. Sequential forward selection does not evaluate all possible
% combinations of features as exhaustive feature selection does.

% All feature selection objects in the Pattern Recognition Toolbox have the
% same API as discussed above.  For a list of all the different objects,
% and links to their individual help entries, <prtDocFunctionList.html#8 A
% list of commonly used functions>