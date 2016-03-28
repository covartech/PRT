function output = prtPath(varargin)
% prtPath Adds necessary directories for the PRT to your path.

if isdeployed
    return;
end

addpath(fullfile(prtRoot,'util'));
origPath = prtUtilGenCleanPath(prtRoot);
addpath(origPath);

for iArg = 1:length(varargin)
    cArg = varargin{iArg};
    cDir = fullfile(prtRoot,cat(2,']',cArg));
    assert(logical(exist(cDir,'file')),']%s is not a directory in %s',cArg,prtRoot);
    P = prtUtilGenCleanPath(cDir,'removeDirStart',{'.'});
    addpath(P);
    origPath = cat(2,origPath,P);
end
if nargout > 0
    output = origPath;
end
