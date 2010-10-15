function List = prtUtilSubDir(directory,match,dirMatch)
% xxx Need Help xxx
% List = prtUtilSubDir(directory,match)

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
    cList = subDir(NewDir,match,dirMatch);
    List = [List;cList];
end
List = [List;cellfun(@(x)fullfile(directory,x),{DC.name}','uniformoutput',false)];
