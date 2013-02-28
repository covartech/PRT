function prtUtilPCode(fileName)

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


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
