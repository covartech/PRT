function List = prtUtilRecursiveDir(directory,match,dirMatch)
% DC = prtUtilRecursiveDir(rootDir)
% DC = prtUtilRecursiveDir(rootDir,fileSpec)
% DC = prtUtilRecursiveDir(rootDir,fileSpec,dirSpec)
% xxx Need Help xxx







if nargin < 2 || isempty(match)
    match = '*';
end

if nargin < 3 || isempty(dirMatch)
    dirMatch = '*';
end

X = dir(fullfile(directory,dirMatch));

Xdir = X(cat(1,X.isdir));

Xdir = Xdir(cellfun(@(x)isempty(strmatch(x,{'.';'..'})),{Xdir.name}));

DC = dir(fullfile(directory,match));
DC = DC(~cat(1,DC.isdir));
List = {};
for ind = 1:length(Xdir)
    NewDir = fullfile(directory,Xdir(ind).name);
    cList = prtUtilRecursiveDir(NewDir,match,dirMatch);
    List = cat(1,List,cList);
end
List = cat(1,List,cellfun(@(x)fullfile(directory,x),{DC.name}','uniformoutput',false));
