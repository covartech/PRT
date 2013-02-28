function prtUtilCreateFunctionList

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
fwrite(fid,sprintf('%% See Copyright notification'));

fclose(fid);

copyfile(tempFileName,fullfile(prtRoot,']internal','doc','prtDocFunctionList.m'));

delete(tempFileName);
