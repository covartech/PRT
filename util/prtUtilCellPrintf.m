function stringCell = prtUtilCellPrintf(sprintfString,cellVals)
%stringCell = prtUtilCellPrintf(sprintfString,cellVals)

stringCell = cell(size(cellVals));
for i = 1:length(cellVals(:))
    stringCell{i} = sprintf(sprintfString,cellVals{i});
end
