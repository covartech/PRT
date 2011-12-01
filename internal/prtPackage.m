function prtPackage(prtTarget)
% prtPackage - Package the release of the PRT into a zip file.

if nargin < 1
    prtTarget = fullfile(getenv('userprofile'),'Desktop','prt');
    if ~isdir(prtTarget)
        mkdir(prtTarget)
    end
end

%Write the Contents.m file in the current directory
disp('Updating contents .m');
oldDir = pwd;
cd(prtRoot);
[v,s] = system('svn info');
cd(oldDir);
s = textscan(s,'%s');
version = s{1}{12};
writeContents(prtRoot,version);

% Commit this new Contents.m
disp('Committing to repo...');
prtVerCtrl('commit','packaging... Updating Contents.m');

% Merge Devel and Release and Create a Release branch marked with the
% version
prtReleaseRoot = fullfile(prtRoot,'..','release'); % Assumes we are working in devel which we have to be because prtPackage doesn't live anywhere else

develSvnRoot = 'http://svn.newfolderconsulting.com/prt/devel';
releaseSvnRoot = 'http://svn.newfolderconsulting.com/prt/release';

% Merge
disp('Merging with release trunk...');
system(sprintf('svn merge %s %s %s --ignore-ancestry',develSvnRoot,releaseSvnRoot,prtReleaseRoot));
% Mark conflicts
system(sprintf('svn resolve -R --accept=working %s',prtReleaseRoot));
% Commit Release
system(sprintf('svn commit %s -m "merging for package"',prtReleaseRoot));


% Branch
disp(cat(2,'Creating release branch ',mat2str(version),'...'));
newSvnRoot = sprintf('http://svn.newfolderconsulting.com/prt/release%s',version);
system(sprintf('svn copy %s %s -m "package"',releaseSvnRoot,newSvnRoot));

% Ok now are ready to actually package things up
if nargin == 0
    prtTarget = fullfile(getenv('userprofile'),'desktop','prt');
end

% If the release already exists we delete it.
if isdir(prtTarget)
    rmdir(prtTarget,'s')
end
   
% SVN Export
disp('Exporting with release branch...');
local = prtReleaseRoot;
target = prtTarget;
command = sprintf('svn export "%s" "%s"',local,target);
system(command);

% P-Code Files - No longer as of 1062
% disp('P-Coding select files...');
% filesToPCode = cat(1,prtUtilSubDir(fullfile(prtTarget,'engine','dataset'),'*.m','asdf'),prtUtilSubDir(fullfile(prtTarget,'engine'),'*.m','asdf'),{fullfile(prtTarget,'util','prtUtilCheckIsValidBeta.m')});
% for iFile = 1:length(filesToPCode)
%     prtUtilPCode(filesToPCode{iFile});
% end



% Copy over documenation
disp('Copying documentation...');
copyfile(fullfile(prtRoot,'doc'),fullfile(prtTarget,'doc'));
rmdir(fullfile(prtTarget,'doc','.svn'),'s') % Delete .svn

if isdir(fullfile(prtTarget,'doc','helpsearch'))
    rmdir(fullfile(prtTarget,'doc','helpsearch'),'s');
end

% Copy the web doc over.
disp('Copying web specific documentation...');
docTarget = fullfile(prtTarget,'..','webDoc');
if ~isdir(fullfile(docTarget))
    mkdir(docTarget)
end
copyfile(fullfile(prtTarget,'doc'), docTarget);
% Copy over the webOnlyDocFiles
copyfile(fullfile(prtRoot,'internal','doc','docWebOnlyFiles'), docTarget);
rmdir(fullfile(docTarget,'.svn'),'s') % Delete .svn

disp('Zipping ...');
zip(cat(2,prtTarget,'.zip'),prtTarget)

disp('Done!');
end

function writeContents(root,version)

string = sprintf('%% Pattern Recognition Toolbox\n%% Version %s %s',version,datestr(now,1));
fid = fopen(fullfile(root,'Contents.m'),'w');
fprintf(fid,'%s',string);
fclose(fid);


end