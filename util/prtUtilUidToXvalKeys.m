function keys = prtUtilUidToXvalKeys(ids,nKeys)
%keys = prtUtilUidToXvalKeys(uids,[nKeys])
%   For vector of scalars of cell-vector of strings IDS, return a scalar
%   array of crossvaliation keys KEYS

% Copyright (c) 2015 CoVar Applied Technologies
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

if nargin<2
	% nKeys not provided. Choose as many folds as possible
	%  = # unique uids
	nKeys = length(unique(ids));
elseif nKeys>length(unique(ids))
	nKeys = length(unique(ids));
	warning('The requested number of keys is greater than the number of unique ids. Using nKeys=%d.',nKeys)
end

% ids may be a vector of scalars, a cell-vector of strings, or a matrix of
% scalars. In the last case, the rows are treated as identifiers.
if isvector(ids)
	[uids,~,ic] = unique(ids);
else
	[uids,~,ic] = unique(ids,'rows');
end
nUids = length(uids);

% Option 1: sort unique ids into bins such that they end up with
%   approximately equal numbers of uids.
ukeys = ceil(randperm(nUids)'/nUids*nKeys);

% Option 2: sort unique ids into bins such that they end up with
%   approximately equal numbers of observations.
% % ids = categorical(ids);
% % counts = countcats(ids);
% % [counts,freqOrder] = sort(counts,'descend');
% % iKey = 1;
% % cIds = 0;
% % nIds = sum(counts);
% % for iUid=1:nUids
% % 	ukeys(freqOrder(iUid)) = iKey; % assign key
% % 	cIds = cIds+counts(iUid); % add to id total
% % 	if cIds/nIds>=1/(nKeys-iKey+1)
% % 		iKey = iKey+1; % advance the key
% % 		nIds = nIds-cIds; % after this, assign the remainder evenly - this might could be recursive
% % 		cIds = 0;
% % 	end
% % end
% THIS METHOD IS DETERMINISTIC! - this may be a more-or-less unavoidable consequence of enforcing similar-sized folds

keys = ukeys(ic);