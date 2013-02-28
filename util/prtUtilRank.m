function [ranks, sortingInds, isTied] = prtUtilRank(ds)
% prtUtilRank - Ranks the vector in increasing magnitude
%   Ties have a rank of the middle of the tied ranks
%   NaNs have a rank of NaN
% 
% prtUtilRank([1 2 2 4 5 inf nan nan]')

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


if ~isnumeric(ds) 
    if isa(ds,'prtDataSetBase')
        ds = ds.getObservations();
    else
        error('prt:prtUtilRank','Input must be either a numerical vector or a prtDataSet containing 1 feature.')
    end
end

if isvector(ds)
    ds = ds(:);
end

assert(size(ds,2)==1,'prtUtilRank is only for 1 dimensional data');

[sortedDS, sortingInds] = sort(ds);

ranks = (1:length(sortedDS))';

if length(sortedDS) > 1
    isTiedWithNext = cat(1,sortedDS(1:(end-1)) == sortedDS(2:end),false);
else
    isTiedWithNext = false;
end

% If there are any ties we need to figure out the tied regions and set each
% of the ranks to the average of the tied ranks.
tieRegions = [];
if any(isTiedWithNext)
    diffIsTiedWithNext = diff(isTiedWithNext);
    
    if isTiedWithNext(1) % First one is tied
        diffIsTiedWithNext = cat(1,1,diffIsTiedWithNext);
    else
        diffIsTiedWithNext = cat(1,0,diffIsTiedWithNext);
    end

    % Start and stop regions of the ties
    tieRegions = cat(2,find(diffIsTiedWithNext==1),find(diffIsTiedWithNext==-1));

    for iRegion = 1:size(tieRegions,1);
        cInds = tieRegions(iRegion,1):tieRegions(iRegion,2);
        
        ranks(cInds) = mean(ranks(cInds));
    end
end
    
ranks(isnan(sortedDS)) = nan;

ranks(sortingInds) = ranks;

if nargout > 2
    % We asked for the isTied vector
    isTied = false(size(ds));
    for iRegion = 1:size(tieRegions,1);
        isTied(tieRegions(iRegion,1):tieRegions(iRegion,2)) = true;
    end
    isTied(sortingInds) = isTied;
end

