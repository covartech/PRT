function [cost,pf,pd] = prtScoreCost(ds,y,costMatrix)
% prtScoreCost  Return the cost vector
%
%    COST = prtScoreCost(DECSTATS,LABELS, COSTMAT) returns the cost vector
%    COST for the decision statistics DECSTATS and the corresponding labels
%    LABELS, according to the cost matrix COSTMAT. DECSTATS must be a Nx1
%    vector of decision statistics. LABELS must be a Nx1 vector of binary
%    class labels. COST must be a 2x2 matrix, where Cij is the cost of
%    deciding i when the truth is j.
%
%    [COST, PF, PD] = prtScoreRoc(DECSTATS,LABELS) returns the probability
%    of false alarm PF, the probability of detection PD at the
%    corresponding COST.
%
%    Example:     
%    TestDataSet = prtDataGenSpiral;       % Create some test and
%    TrainingDataSet = prtDataGenSpiral;   % training data
%    classifier = prtClassSvm;             % Create a classifier
%    classifier = classifier.train(TrainingDataSet);    % Train
%    classified = run(classifier, TestDataSet);     
%    %  Compute the cost vector
%    C = prtScoreCost(classified.getX, TestDataSet.getY, [1 .1; .1 1]);
%
%   See also prtScoreConfusionMatrix, prtScoreRmse,
%   prtScorePercentCorrect







[ds,y] = prtUtilScoreParseFirstTwoInputs(ds,y);
[pf,pd] = prtScoreRoc(ds,y);
cost = prtUtilPfPd2Cost(pf,pd,costMatrix);
