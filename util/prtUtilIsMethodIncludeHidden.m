function tf = prtUtilIsMethodIncludeHidden(obj,methName)
% xxx Need Help xxx
% Internal







m = metaclass(obj);
tf = ismember(methName,cellfun(@(c)c.Name,m.Methods,'uniformoutput',false));
