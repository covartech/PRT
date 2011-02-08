function [classes,uStrings] = prtUtilStringsToClassNumbers(stringCell,uStrings)
%[classes,uniqueStrings] = prtUtilStringsToClassNumbers(stringCell)
%[classes,uniqueStrings] = prtUtilStringsToClassNumbers(stringCell,uStrings)
% xxx Need Help xxx

if nargin < 2
    uStrings = unique(stringCell);
end
classes = zeros(length(stringCell),1);
for i = 1:length(uStrings);
    classes(strcmpi(uStrings{i},stringCell)) = i;
end