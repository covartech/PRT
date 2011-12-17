function prtPublishDoc
%prtPublishDoc
%   Utility function to publish all prtPublish* M-files in prtRoot\doc to
%   HTML files.

docHtmlDir = fullfile(prtRoot,'doc');
docMDir = fullfile(prtRoot,']internal','doc');

mfilelist = prtUtilSubDir(docMDir,'prtDoc*.m');

PublishOptions.format = 'html';
PublishOptions.outputDir = docHtmlDir;

for i = 1:length(mfilelist)
    publish(mfilelist{i},PublishOptions);
end
close all;

prtUtilCreateFunctionList;
prtUtilCreateFunctionReference;