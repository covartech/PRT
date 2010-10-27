function auc = prtScoreAuc(ds,y)
% prtScoreAuc Calculates the area under the ROC curve
%
% See:
% http://www.springerlink.com/content/nn141j42838n7u21/fulltext.pdf

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
dsRank(isnan(dsRank)) = 0; % Nans are interpreted at the front of the roc.

nH1 = sum(isH1);
nH0 = sum(isH0);

auc = (sum(dsRank(isH1)) - nH1*(nH0+1)/2) / (nH0*nH1);