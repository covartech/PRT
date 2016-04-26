function groupAssignment = prtUtilEquallySubDivideData(Y,nDivisions)
% prtUtilEquallySubDivideData  Equally sub-divide into several groups.
%   By equally sub-divide I mean make it so that each group has the same
%   number of data points of each class.
%
% Syntax: groupAssignment = prtUtilEquallySubDivideData(Y,nDivisions)
%
% Inputs:
%   Y - The class label vector for the dataset
%   nDivision - The number of division to make
%
% Outputs:
%   groupAssignment = Integer assignments specifying the group for each
%       datapoint. These are randomly drawn
%








if nDivisions > length(Y)
   warning('The number of requested divisions is larger than the amount of data. The number of divisions was changed to the length of the data.')
   nDivisions = length(Y);
end

% Leave One Out quick method...
if nDivisions == length(Y)
   groupAssignment = randperm(nDivisions)';
   return
end

% Y may contain NaNs. These are treated at missing data. All NaNs are
% distributed evenly across the folds. To do this we make a virtual class
% for nan and then use the same code below.
nanVals = isnan(Y);
if any(nanVals)
    Y(nanVals) = max(Y(~nanVals))+1;
end

sortedY = sort(Y);
nSamples = length(Y);
sortedGroupAssignment = repmat((1:nDivisions)',ceil(nSamples/nDivisions),1);
sortedGroupAssignment = sortedGroupAssignment(1:nSamples);

% Randomize within each class and revert back to the original order
groupAssignment = zeros(size(Y));
uY = unique(Y);
nClasses = length(uY);
for iClass = 1:nClasses
   cSortedGroupAssignment = sortedGroupAssignment(sortedY == uY(iClass));
   groupAssignment(Y==uY(iClass)) = cSortedGroupAssignment(randperm(sum(sortedY == uY(iClass))));
end

