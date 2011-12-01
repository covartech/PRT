function prtUtilCreateFunctionList

[~,listFunctions] = cellfun(@(c)fileparts(c),prtUtilSubDir(prtRoot,'prtUtilList*.m'),'uniformOutput',false);

nestedList = cell(length(listFunctions),1);
for iList = 1:length(listFunctions)
    nestedList{iList} = feval(listFunctions{iList});
end

tempFileName = fullfile(pwd,'tempHelpList.m');
fid = fopen(tempFileName,'w+');

fwrite(fid,sprintf('%%%% PRT Objects and Functions By Category\n'));
fwrite(fid,sprintf('%% Pattern Recognition Toolbox\n'));
fwrite(fid,sprintf('%%\n'));

for iList = 1:length(listFunctions)
    if strcmpi(listFunctions{iList},'prtUtilListEngine')
        fwrite(fid,sprintf('%%%% PRT Engine\n'));
    else
        fwrite(fid,sprintf('%%%% %s\n',strrep(listFunctions{iList},'prtUtilList','prt')));
    end
    for iSubList = 1:length(nestedList{iList})
        [dontNeed, cFunName] = fileparts(nestedList{iList}{iSubList});
        fwrite(fid,sprintf('%% * <%s %s>\n',cat(2,'./functionReference/',cFunName,'.html'),cFunName));
    end
    fwrite(fid,sprintf('%%\n'));
end
fwrite(fid,sprintf('%% Copyright 2011 New Folder Consulting L.L.C.'));

fclose(fid);

copyfile(tempFileName,fullfile(prtRoot,'internal','doc','prtDocFunctionList.m'));

delete(tempFileName);
