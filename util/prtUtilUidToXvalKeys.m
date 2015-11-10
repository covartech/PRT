function keys = prtUtilUidToXvalKeys(ids,varargin)
%keys = prtUtilUidToXvalKeys(uids,[labels],[nKeys])
%   For a vector of scalars OR cell-vector of strings, return a scalar
%   array of crossvaliation keys
%
% Example:
% ids = {'a','b','c','b','a','c','d','d'};
% labels = [0,0,0,1,1,1,1,1];
% nKeys = 3;
% prtUtilUidToXvalKeys(ids,labels,nKeys)

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

nObservations = length(ids);

% If nKeys is not provided, choose as many folds as possible
%  = # unique uids.
% If labels are not provided, assume everything is H1.
if nargin<2
	% neither labels nor nKeys provided
	labels = ones(nObservations,1);
	nKeys = length(unique(ids));
elseif nargin==2
	if isscalar(varargin{1})
		% only nKeys provided
		labels = ones(nObservations,1);
		nKeys = varargin{1};
	elseif isvector(varargin{1})
		% only labels provided
		labels = varargin{1};
		nKeys = length(unique(ids));
	end
elseif nargin==3
	% both labels and nKeys provided
	labels = varargin{1};
	nKeys = varargin{2};
end

assert(length(labels)==nObservations,'The number of ids and labels should be the same.');

% extract the number and indices of each id in each class
ulabels = unique(labels);
nClasses = length(ulabels);
uids = cell(nClasses,1);
ic = cell(nClasses,1);
nUids = nan(nClasses,1);
for iClass = 1:nClasses % for each class
	[uids{iClass},~,ic{iClass}] = unique(ids(labels==ulabels(iClass)));
	nUids(iClass) = length(uids{iClass});
end

% sort by increasing number of ids per class
[nUids,classOrder] = sort(nUids);
ic = ic(classOrder);
ulabels = ulabels(classOrder);

% are too many keys requested? fix it.
if nKeys>min(nUids)
	[minNUids,iClass] = min(nUids);
	warning('The requested number of keys (%d) is greater than the number of unique ids in class %d (%d). Using nKeys=%d.',...
		nKeys,ulabels(iClass),minNUids,minNUids)
	nKeys = minNUids;
end

% Assign keys to unique ids such that each key ends up with approximately
% equal numbers of uids.
ukeys = cell(nClasses,1);
% Assign keys uniformly across the ids found in all classes.
ukeys{1} = ceil(randperm(min(nUids))'/min(nUids)*nKeys);
% What follows was written assuming that nClasses==2, though it may not be
% readily apparent. DO NOT expect it to work for nClasses>2.
if nClasses>2
	warning('This is not yet implemented for >2 classes. The results may not be what you want.')
end
% Assign keys uniformly across the remaining ids
% but backwards, to help keep the assignments uniform.
for iClass = 2:nClasses
	ukeys{iClass} = cat(1,ceil(randperm(min(nUids))'/min(nUids)*nKeys),...
		nKeys+1-ceil(randperm((max(nUids)-min(nUids)))'/(max(nUids)-min(nUids))*nKeys));
end
% Assign the keys to the observations.
keys = nan(nObservations,1);
for iClass = 1:nClasses
	keys(labels==ulabels(iClass)) = ukeys{iClass}(ic{iClass});
end

% TESTING
% The following should display only empty matrices:
% % keyPairs = nchoosek(1:nKeys,2);
% % for iPair = 1:size(keyPairs,1)
% % 	intersect(unique(ids(keys==keyPairs(iPair,1))),unique(ids(keys==keyPairs(iPair,2))))
% % end