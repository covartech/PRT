function [classes,uStrings] = prtUtilStringsToClassNumbers(stringCell)
%[classes,uniqueStrings] = prtUtilStringsToClassNumbers(stringCell)

uStrings = unique(stringCell);
classes = zeros(length(stringCell),1);
for i = 1:length(uStrings);
    classes(strcmpi(uStrings{i},stringCell)) = i;
end