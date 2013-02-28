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

