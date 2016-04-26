function [classes,uStrings] = prtUtilStringsToClassNumbers(stringCell,uStrings)
%[classes,uniqueStrings] = prtUtilStringsToClassNumbers(stringCell)
%[classes,uniqueStrings] = prtUtilStringsToClassNumbers(stringCell,uStrings)
% xxx Need Help xxx







if nargin < 2
    [uStrings,~,classes] = unique(stringCell);
    return;
end
classes = nan(length(stringCell),1);
for i = 1:length(uStrings);
    classes(strcmpi(uStrings{i},stringCell)) = i;
end
