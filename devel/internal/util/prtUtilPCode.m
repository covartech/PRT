function prtUtilPCode(fileName)

% Create P-File Version
pcode(fileName,'-inplace');

mfileStr = help(fileName);

% Delete M-File Version
delete(fileName); 

% Make new mfile with just the help.
[pathName, cFuncName] = fileparts(fileName);

mfileStr = cat(2,mfileStr,sprintf('\n  For more help and information regarding the properties and methods \n  see <a href="matlab:prtDoc(''%s'')">%s Function Reference</a>\n',cFuncName,cFuncName));

fid = fopen(fileName,'w+');
fwrite(fid,mfileStr);
fclose(fid);
