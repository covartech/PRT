function pathStr = prtUtilStrCell2MatlabPath(strCell)
%pathCell = prtUtilStrCell2MatlabPath(strCell)

pathStr = sprintf('%s;',strCell{:});
