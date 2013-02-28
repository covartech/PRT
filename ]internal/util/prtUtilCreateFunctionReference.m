function prtUtilCreateFunctionReference(saveRoot)

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


if nargin < 1
    saveRoot = prtRoot;
end

if isdir(fullfile(prtRoot,'doc','functionReference'))
    rmdir(fullfile(prtRoot,'doc','functionReference'),'s');
end

[~,listFunctions] = cellfun(@(c)fileparts(c),prtUtilSubDir(prtRoot,'prtUtilList*.m'),'uniformOutput',false);

for iList = 1:length(listFunctions)
    prtUtilClassNameToHtmlDoc(listFunctions{iList}, saveRoot)
end

% prtUtilClassNameToHtmlDoc('prtDataSetBase',saveRoot)
% prtUtilClassNameToHtmlDoc('prtDataSetStandard',saveRoot)
% prtUtilClassNameToHtmlDoc('prtDataSetRegress',saveRoot)
% prtUtilClassNameToHtmlDoc('prtDataSetClass',saveRoot)
% 
% prtUtilClassNameToHtmlDoc('prtAction',saveRoot)
% prtUtilClassNameToHtmlDoc('prtClass',saveRoot)
% prtUtilClassNameToHtmlDoc('prtDecision',saveRoot)
% prtUtilClassNameToHtmlDoc('prtFeatSel',saveRoot)
% prtUtilClassNameToHtmlDoc('prtPreProc',saveRoot)
% prtUtilClassNameToHtmlDoc('prtOutlierRemoval',saveRoot)
% prtUtilClassNameToHtmlDoc('prtRegress',saveRoot)
% prtUtilClassNameToHtmlDoc('prtCluster',saveRoot)
