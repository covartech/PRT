function stringCell = prtUtilCellPrintf(sprintfString,cellVals)
%stringCell = prtUtilCellPrintf(sprintfString,cellVals)
% xxx Need Help xxx

stringCell = cellfun(@(s)sprintf(sprintfString,s),cellVals,'UniformOutput',false);
