function prtUtilClassNameToHtmlDoc(topic,packageRoot)
% prtUtilClassNameToHtmlDoc

if nargin < 2
    packageRoot = prtRoot;
end

saveDir = fullfile(packageRoot,'doc','functionReference');

outStr = help2html(topic,topic,'-doc');

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
    if strcmpi(outStr((cStartInd-6):(cStartInd-1)),'href="');
        % Already have the href
        outStr = strrep(outStr,cStr,sprintf('./%s.html',strrep(subPropsAndMethods{iRef},'.','/')));
    else
        % Need to add the href ourselves
        outStr = strrep(outStr,cStr,sprintf('<a href="./%s.html">%s</a>',strrep(subPropsAndMethods{iRef},'.','/'),subPropsAndMethods{iRef}));
    end
end

subPropsAndMethods2 = regexp(outStr,'matlab:doc (?<funcNames>[\w\.]+)?"','tokens');
subPropsAndMethods2 = cellfun(@(c)c{1},subPropsAndMethods2(:),'uniformoutput',false);
for iRef = 1:length(subPropsAndMethods2)
    cStr = sprintf('matlab:doc %s',subPropsAndMethods2{iRef});
    
    % Need to add the href ourselves
    outStr = strrep(outStr,cStr,sprintf('./%s.html',strrep(subPropsAndMethods2{iRef},'.','/')));
end

subPropsAndMethods3 = regexp(outStr,'matlab:helpwin (?<funcNames>[\w\.]+)?"','tokens');
subPropsAndMethods3 = cellfun(@(c)c{1},subPropsAndMethods3(:),'uniformoutput',false);
for iRef = 1:length(subPropsAndMethods3)
    cStr = sprintf('matlab:helpwin %s',subPropsAndMethods3{iRef});
    
    % Need to add the href ourselves
    outStr = strrep(outStr,cStr,sprintf('./%s.html',strrep(subPropsAndMethods3{iRef},'.','/')));
end

outStr = regexprep(outStr,'<td class="subheader-left">.*?</td>','');
outStr = regexprep(outStr,'<td class="subheader-right">.*?</td>','');

cssStr = cat(2,repmat('../',1,sum(topic=='.')+1),'helpwin.css');

outStr = regexprep(outStr,'<link rel="stylesheet" .*?>',sprintf('<link rel="stylesheet" href="./%s">',cssStr));
    
% Write the html file
newFullFileName = cat(2,fullfile(saveDir,strrep(topic,'.',filesep)),'.html');

newPathName = fileparts(newFullFileName);
if ~isdir(newPathName)
    mkdir(newPathName);
end

fid = fopen(newFullFileName,'w+');
fwrite(fid,outStr);
fclose(fid);

if isempty(subPropsAndMethods)
    return
end

subPropsAndMethods = cat(1,subPropsAndMethods(:),subPropsAndMethods2(:),subPropsAndMethods3(:));

% For each of these properties and methods we must also make the
% documenation (if it doesn't already exist).
for iRef = 1:length(subPropsAndMethods)
    nextFile = cat(2,fullfile(saveDir,strrep(subPropsAndMethods{iRef},'.',filesep)),'.html');
    if ~exist(nextFile,'file')
        prtUtilClassNameToHtmlDoc(subPropsAndMethods{iRef},packageRoot);
    end
end