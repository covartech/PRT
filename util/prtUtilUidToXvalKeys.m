function keys = prtUtilUidToXvalKeys(ids,varargin)
%keys = prtUtilUidToXvalKeys(uids,[labels],[nKeys])
%   For a vector of scalars OR cell-vector of strings, return a scalar
%   array of crossvalidation keys
%
% Example:
% ids = {'a','b','c','b','a','c','d','d'};
% labels = [0,0,0,1,1,1,1,1];
% nKeys = 3;
% prtUtilUidToXvalKeys(ids,labels,nKeys)

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
nUids = nan(nClasses,1);

icByClass = cell(nClasses,1);
[uids,~,ic] = unique(ids);
for iClass = 1:nClasses % for each class
	icByClass{iClass} = unique(ic(labels==ulabels(iClass)));
	nUids(iClass) = length(icByClass{iClass});
end

% sort by increasing number of ids per class
[nUids,classOrder] = sort(nUids);
ulabels = ulabels(classOrder);
icByClass = icByClass(classOrder);

% are too many keys requested? fix it.
if nKeys>min(nUids)
	[minNUids,iClass] = min(nUids);
	warning('The requested number of keys (%d) is greater than the number of unique ids in class %d (%d). Using nKeys=%d.',...
		nKeys,ulabels(iClass),minNUids,minNUids)
	nKeys = minNUids;
end

% Assign keys uniformly across the ids found in the smallest class.
ukeys(icByClass{1}) = ceil(randperm(min(nUids))'/min(nUids)*nKeys);
assigned = icByClass{1};
% Assign keys uniformly across the remaining ids
% but backwards, to help keep the assignments uniform-ish.
for iClass = 2:nClasses
    toAssign = setdiff(icByClass{iClass},assigned);
	ukeys(toAssign) = nKeys+1-ceil(randperm(length(toAssign))'/length(toAssign)*nKeys);
    assigned = cat(1,assigned,toAssign);
end
% Assign the keys to the observations.
keys = nan(nObservations,1);
for iUid = 1:length(uids)
    keys(ic==iUid) = ukeys(iUid);
end

% TESTING
% The following should display only empty matrices:
% % keyPairs = nchoosek(1:nKeys,2);
% % for iPair = 1:size(keyPairs,1)
% % 	intersect(unique(ids(keys==keyPairs(iPair,1))),unique(ids(keys==keyPairs(iPair,2))))
% % end