function prtUtilPCode(fileName)

% Create P-File Version
pcode(fileName,'-inplace');

mfileStr = help(fileName);

% Delete M-File Version
delete(fileName); 

% Make new mfile with just the help.
[pathName, cFuncName] = fileparts(fileName);

mfileStr = cat(2,mfileStr,sprintf('\n  For more help and information regarding the properties and methods \n  see <a href="matlab:prtDoc(''%s'')">%s Function Reference</a>\n',cFuncName,cFuncName));

returnChar = mfileStr(find(double(mfileStr)==10,1,'first'));
mfileStr = strrep(mfileStr,returnChar,cat(2,returnChar,'%'));

mfileStr = cat(2,mfileStr,'%');

fid = fopen(fileName,'w+');
fwrite(fid,mfileStr);
fclose(fid);

% Matlab throws warnings if the help m files are new than the p-coded
% files. So we have to copy stuff around.


% copyfile(pFileName, fullfile(tempdir,cat(2,cFuncName,'.p')));
% delete(pFileName)
% copyfile(fullfile(tempdir,cat(2,cFuncName,'.p')),pFileName);

pFileName = cat(2,fullfile(pathName,cFuncName),'.p');
system(sprintf('copy /b "%s" +,,',pFileName)); % Touch file and put it in current dir
movefile(fullfile(pwd,cat(2,cFuncName,'.p')),pFileName); % move it to the right place
