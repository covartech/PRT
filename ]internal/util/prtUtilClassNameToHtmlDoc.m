function prtUtilClassNameToHtmlDoc(topic,packageRoot)
% prtUtilClassNameToHtmlDoc

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


if nargin < 2
    packageRoot = prtRoot;
end

saveDir = fullfile(packageRoot,'doc','functionReference');

periodLoc = find(topic=='.',1,'first');
if ~isempty(periodLoc)
    mFileOnly = topic(1:periodLoc-1);
else
    mFileOnly = topic;
end

mFilePath = which(mFileOnly);

if isempty(mFilePath) || isempty(strfind(mFilePath,packageRoot))
    % File doesn't exist or is not in packageRoot
    return
end

outStr = help2html(topic,topic,'-doc');

outStr = strtrim(outStr);

if isempty(outStr)
    
    str = fileread(fullfile(prtRoot,']internal','util','prtUtilDefaultHtml.html'));
    str = strrep(str,'<funcName>',topic);
    
    cssStr = cat(2,repmat('../',1,sum(topic=='.')+1),'helpwin.css');
    
    str = strrep(str,'<cssFile>',cssStr);
    
    writeHtml(saveDir,topic,str);
    return
end

% Now outStr is a big block of html
% Problem is, it contains calls to matlab:helpwin(...) but since we are
% making html doc for use elsewhere (web) or with p-coded files. We need to
% change all of these references to html pages, but they aren't html pages.
% So we have to make those also.

subPropsAndMethods = regexp(outStr,'matlab:helpwin(''(?<funcNames>[\w\.]+?'')','tokens');
subPropsAndMethods = cellfun(@(c)c{1}(1:end-1),subPropsAndMethods(:),'uniformoutput',false);

% For this html file we need to replace each of these matlab:helpwin()
% calls with a proper hyperlink
for iRef = 1:length(subPropsAndMethods)
    cStr = sprintf('matlab:helpwin(''%s'')',subPropsAndMethods{iRef});
    cStartInd = strfind(outStr,cStr);
    
    linkStr = topicToLink(topic,subPropsAndMethods{iRef});
    
    if strcmpi(outStr((cStartInd-6):(cStartInd-1)),'href="');
        % Already have the href
        %outStr = regexprep(outStr,cat(2,'"',cStr,'?"'),cat(2,'"',sprintf('./%s.html',strrep(subPropsAndMethods{iRef},'.','/')),'"'));
        outStr = strrep(outStr,cat(2,'<a href="',cStr,'">'),sprintf('<a href="%s">',linkStr));
    else
        % Need to add the href ourselves
        outStr = strrep(outStr,cStr,sprintf('<a href="%s">%s</a>',linkStr,subPropsAndMethods{iRef}));
    end
end

subPropsAndMethods2 = regexp(outStr,'matlab:doc (?<funcNames>[\w\.\/]+)?"','tokens');
subPropsAndMethods2 = cellfun(@(c)c{1},subPropsAndMethods2(:),'uniformoutput',false);
for iRef = 1:length(subPropsAndMethods2)
    cStr = sprintf('matlab:doc %s',subPropsAndMethods2{iRef});

    linkStr = topicToLink(topic,subPropsAndMethods2{iRef});
       
    
    % No need to add the href ourselves
    outStr = regexprep(outStr,cat(2,'"',cStr,'?"'),cat(2,'"',linkStr,'"'));
end

subPropsAndMethods3 = regexp(outStr,'matlab:helpwin (?<funcNames>[\w\.]+)?"','tokens');
subPropsAndMethods3 = cellfun(@(c)c{1},subPropsAndMethods3(:),'uniformoutput',false);
for iRef = 1:length(subPropsAndMethods3)
    cStr = sprintf('matlab:helpwin %s',subPropsAndMethods3{iRef});
    
    linkStr = topicToLink(topic,subPropsAndMethods3{iRef});
    
    % No need to add the href ourselves
    outStr = regexprep(outStr,cat(2,'"',cStr,'?"'),cat(2,'"',linkStr,'"'));
end

outStr = regexprep(outStr,'<td class="subheader-left">.*?</td>','');
outStr = regexprep(outStr,'<td class="subheader-right">.*?</td>','');

cssStr = cat(2,repmat('../',1,sum(topic=='.')+1),'helpwin.css');

outStr = regexprep(outStr,'<link rel="stylesheet" .*?>',sprintf('<link rel="stylesheet" href="./%s">',cssStr));
    
writeHtml(saveDir,topic,outStr);

subPropsAndMethods = cat(1,subPropsAndMethods(:),subPropsAndMethods2(:),subPropsAndMethods3(:));

if isempty(subPropsAndMethods)
    return
end

% For each of these properties and methods we must also make the
% documenation (if it doesn't already exist). % And it's in the PRT
for iRef = 1:length(subPropsAndMethods)
    nextFile = cat(2,fullfile(saveDir,strrep(subPropsAndMethods{iRef},'.',filesep)),'.html');
    
    if ~exist(nextFile,'file') && ~isempty(strfind(nextFile,packageRoot))
        prtUtilClassNameToHtmlDoc(subPropsAndMethods{iRef},packageRoot);
    end
end

end


function writeHtml(saveDir,topic,outStr)

% Write the html file
newFullFileName = cat(2,fullfile(saveDir,strrep(topic,'.',filesep)),'.html');

newPathName = fileparts(newFullFileName);
if ~isdir(newPathName)
    mkdir(newPathName);
end

fid = fopen(newFullFileName,'w+');
fwrite(fid,outStr);
fclose(fid);
end

function linkStr = topicToLink(pageTopic,linkTopic)

linkStr = cat(2,'./',repmat('../',1,sum(pageTopic=='.')),strrep(linkTopic,'.','/'),'.html');


end
