function prtPackage(prtTarget)
% prtPackage - Package the release of the PRT into a zip file.

%Write the Contents.m file in the current directory
oldDir = pwd;
cd(prtRoot);
[v,s] = system('svn info');
cd(oldDir);
s = textscan(s,'%s');
version = s{1}{12};
writeContents(prtRoot,version);

% Commit this new Contents.m
prtVerCtrl('commit','packaging... Updating Contents.m');

% Merge Devel and Release and Create a Release branch marked with the date
prtReleaseRoot = fullfile(prtRoot,'..','release'); % Assumes we are working in devel which we have to be because prtPackage doesn't live anywhere else

develSvnRoot = 'http://svn.newfolderconsulting.com/prt/devel';
releaseSvnRoot = 'http://svn.newfolderconsulting.com/prt/release';

% Merge
system(sprintf('svn merge %s %s %s --ignore-ancestry',develSvnRoot,releaseSvnRoot,prtReleaseRoot));
% Mark conflicts
system(sprintf('svn resolve -R --accept=working %s',prtReleaseRoot));
% Commit Release
system(sprintf('svn commit %s -m "merging for package"',prtReleaseRoot));


% Branch
newSvnRoot = sprintf('http://svn.newfolderconsulting.com/prt/release%s',datestr(now,'yyyymmdd'));
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
local = prtReleaseRoot;
target = prtTarget;
command = sprintf('svn export "%s" "%s"',local,target);
system(command);

% P-Code Files
filesToPCode = cat(1,prtUtilSubDir(fullfile(prtTarget,'engine','dataset'),'*.m','asdf'),prtUtilSubDir(fullfile(prtTarget,'engine'),'*.m','asdf'),{fullfile(prtTarget,'util','prtUtilCheckIsValidBeta.m')});
for iFile = 1:length(filesToPCode)
    prtUtilPCode(filesToPCode{iFile});
end

% Copy over documenation
copyfile(fullfile(prtRoot,'doc'),fullfile(prtTarget,'doc'));
rmdir(fullfile(prtTarget,'doc','.svn'),'s') % Delete .svn

zip(cat(2,prtTarget,'.zip'),prtTarget)

end

function writeContents(root,version)

string = sprintf('%% Pattern Recognition Toolbox\n%% Version %s %s',version,datestr(now,1));
fid = fopen(fullfile(root,'Contents.m'),'w');
fprintf(fid,'%s',string);
fclose(fid);


end