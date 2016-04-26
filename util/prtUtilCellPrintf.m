function stringCell = prtUtilCellPrintf(sprintfString,cellVals)
%stringCell = prtUtilCellPrintf(sprintfString,cellVals)
% xxx Need Help xxx






if isnumeric(cellVals)
    cellVals = num2cell(cellVals);
end
   

stringCell = cellfun(@(s)sprintf(sprintfString,s),cellVals,'UniformOutput',false);
