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

nH1 = sum(isH1);
nH0 = sum(isH0);

% If there are nans we need to account
nanSpots = isnan(dsRank);

nNansH1 = sum(nanSpots & isH1);
nNansH0 = sum(nanSpots & isH0);

nH1NonNans = nH1-nNansH1;
nH0NonNans = nH0-nNansH0;

auc = (nansum(dsRank(isH1)) - nH1NonNans*(nH1NonNans+1)/2) / (nH0NonNans*nH1NonNans);

if any(nanSpots)
    % With nans we need to correct for the uncovered region
    auc = auc*(1-nNansH1/nH1)*(1-nNansH0/nH0);
end