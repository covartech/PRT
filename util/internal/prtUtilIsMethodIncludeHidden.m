function tf = prtUtilIsMethodIncludeHidden(obj,methName)

m = metaclass(obj);
tf = ismember(methName,cellfun(@(c)c.Name,m.Methods,'uniformoutput',false));