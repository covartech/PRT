function [nf,pd,auc,thresholds,classLabels] = prtScoreRocNfa(ds,y,varargin)
% prtScoreRocNfa   Generate a operator characteristic curve and output the number of false alarms
%
%    prtScoreRocNfa(DECSTATS,LABELS) plots the receiver operator
%    characteristic curve for the decision statistics DECSTATS and the
%    corresponding labels LABELS. DECSTATS must be a Nx1 vector of decision
%    statistics. LABELS must be a Nx1 vector of binary class labels. This
%    behavior is the same as prtScoreRoc.
%
%    [NF, PD, AUC] = prtScoreRocNfa(DECSTATS,LABELS, NFA) outputs the number
%    of false alarms NF, the probability of detection PD, and the area
%    under the ROC scurve AUC.
%
%    Example:     
%    TestDataSet = prtDataGenSpiral;       % Create some test and
%    TrainingDataSet = prtDataGenSpiral;   % training data
%    classifier = prtClassSvm;             % Create a classifier
%    classifier = classifier.train(TrainingDataSet);    % Train
%    classified = run(classifier, TestDataSet);     
%    % Find the number of false alarms at the corresponding PD.
%    [nf, pd ]= prtScoreRocNfa(classified.getX, TestDataSet.getY);
%
%   See also prtScoreConfusionMatrix, prtScoreRmse,
%   prtScoreRocBayesianBootstrap, prtScoreRocBayesianBootstrapNfa,
%   prtScorePercentCorrect



% rocNFA - Generate a PD vs. # FA pseudo-ROC curve.
%
%   Syntax: [NF,PD] = rocNfa(...)
%
%   Inputs:
%       See roc.m
%
%   Outputs:
%       NF - double Vec - Similar to Pf (see roc.m) but taking discrete integer values
%       corresponding to 1, 2, 3, ... N false alarms.
%       
%       PD - double Vec - Probability of detection
%

% Copyright 2010, New Folder Consulting, L.L.C.

[pf,pd,auc,thresholds,classLabels] = prtScoreRoc(ds,y,varargin{:});
nMiss = length(find(y == 0));
nf = pf*nMiss;

if nargout == 0
    plot(nf,pd);
    xlabel('#FA');
    ylabel('Pd');
    
    clear nf pd auc thresholds classLabels
end
