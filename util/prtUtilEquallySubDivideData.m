function groupAssignment = prtUtilEquallySubDivideData(Y,nDivisions)
% prtUtilEquallySubDivideData  Equally sub-divide into several groups.
%   By equally sub-divide I mean make it so that each group has the same
%   number of data points of each class.
%
% Syntax: groupAssignment = dprtEquallySubDivideData(Y,nDivisions)
%
% Inputs:
%   Y - The class label vector for the dataset
%   nDivision - The number of division to make
%
% Outputs:
%   groupAssignment = Integer assignments specifying the group for each
%       datapoint. These are randomly drawn
%
% Example:
%   X0 = mvnrnd([0 0],eye(2),500);
%   X1 = mvnrnd([2.5 2.5],eye(2),500);
%   X = [X0; X1];
%   Y = [zeros(500,1); ones(500,1)];
% 
%   % Divide the data into two equally sized groups
%   groupAssignment = dprtEquallySubDivideData(Y,2);
%   figure
%   subplot(2,1,1)
%   dprtDataPlot(X,Y,true)
%   title('All Data')
%   subplot(2,2,3)
%   dprtDataPlot(X(groupAssignment==1,:),Y(groupAssignment==1),true)
%   title('Group 1')
%   subplot(2,2,4)
%   dprtDataPlot(X(groupAssignment==2,:),Y(groupAssignment==2),true)
%   title('Group 2')
%   % Other m-files required: DPRT
% Subfunctions: none
% MAT-files required: none
%
% See also: dprtKFolds.m

% Author: Kenneth D. Morton Jr.
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 23-Feb-2007


if nDivisions > length(Y)
   warning('The number of requested divisions is larger than the amount of data. The number of divisions was changed to the length of the data.')
   nDivisions = length(Y);
end

% Leave One Out quick method...
if nDivisions == length(Y)
   groupAssignment = randperm(nDivisions)';
   return
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

