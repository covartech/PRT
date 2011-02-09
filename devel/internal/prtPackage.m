function prtPackage(prtTarget)

prtReleaseRoot = fullfile(prtRoot,'..','release');
%matlab32exe = 'C:\Program Files (x86)\MATLAB\R2010b\bin\win32\MATLAB.exe';

if nargin == 0
    prtTarget = fullfile(getenv('userprofile'),'desktop','prt');
end

if isdir(prtTarget)
    rmdir(prtTarget,'s')
end
   
%Write the contents.m file
oldDir = pwd;
cd(prtRoot);
[v,s] = system('svn info');
cd(oldDir);
s = textscan(s,'%s');
version = s{1}{12};

string = sprintf('%% Pattern Recognition Toolbox\n%% Version %s %s',version,datestr(now,1));
fid = fopen(fullfile(prtReleaseRoot,'Contents.m'),'w');
fprintf(fid,'%s',string);
fclose(fid);

fid = fopen(fullfile(prtRoot,'Contents.m'),'w');
fprintf(fid,'%s',string);
fclose(fid);

% Commit the updated Contents.m
% prtVerCtrl('commit',sprintf('packaging revision %s',version));

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

%prtUtilCreateFunctionReference(prtTarget);

% Copy over documenation
copyfile(fullfile(prtRoot,'doc'),fullfile(prtTarget,'doc'));


end