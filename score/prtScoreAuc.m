function auc = prtScoreAuc(ds,y)
% prtScoreAuc Calculates the area under the ROC curve
%
%   AUC  = prtScoreAuc(GUESS, TRUTH) returns the
%   percent of correct guesses in GUESS as compared to the truth in TRUTH.
%   GUESS and TRUTH should both be Nx1 vectors. The elements of both
%   TRUTH and GUESS should be binary or interger class labels.
%
%
%   Example:
%   TestDataSet = prtDataGenUnimodal;       % Create some test and
%   TrainingDataSet = prtDataGenUnimodal;   % training data
%   classifier = prtClassMap;               % Create a classifier
%   classifier = classifier.train(TrainingDataSet);    % Train
%   classified = run(classifier, TestDataSet);         % Test
%   auc = prtScoreAuc(classified,TestDataSet)
%
%   See also prtScoreConfusionMatrix, prtScoreRoc, prtScoreRmse








if nargin < 2
    y = [];
end

[ds,y] = prtUtilScoreParseFirstTwoInputs(ds,y);

uY = unique(y);

assert(length(uY)<3,'prtScoreAuc is only for binary classificaiton problems.');

isH0 = y==uY(1);
if length(uY) > 1
    isH1 = y==uY(2);
else
    isH1 = false(size(isH0));
end

dsRank = prtUtilRank(ds);

nH1 = sum(isH1);
nH0 = sum(isH0);

% If there are nans we need to account
nanSpots = isnan(dsRank);

nNansH1 = sum(nanSpots & isH1);
nNansH0 = sum(nanSpots & isH0);

nH1NonNans = nH1-nNansH1;
nH0NonNans = nH0-nNansH0;

%nansum is only in 2010... need to be compatible with 2009A
%auc = (nansum(dsRank(isH1)) - nH1NonNans*(nH1NonNans+1)/2) / (nH0NonNans*nH1NonNans);
auc = (sum(dsRank(isH1 & ~isnan(dsRank))) - nH1NonNans*(nH1NonNans+1)/2) / (nH0NonNans*nH1NonNans);

if any(nanSpots)
    % With nans we need to correct for the uncovered region
    auc = auc*(1-nNansH1/nH1)*(1-nNansH0/nH0);
end
