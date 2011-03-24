function prtPackageDoc(targetDir)

% Publish the new doc
prtPublishDoc

% Copy all of the files over
copyfile(fullfile(prtRoot,'doc'),fullfile(targetDir,'doc'));
rmdir(fullfile(prtTarget,'doc','.svn'),'s') % Delete .svn
