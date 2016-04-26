function W = prtUtilRecursiveWhat(directory)
% xxx Need Help xxx







dirList = dir(directory);
W = what(directory);

skipDirs = {'.','..','.svn'};
for i = 1:length(dirList)  %skip '.', '..'
    if ~any(strcmpi(dirList(i).name,skipDirs))
        if dirList(i).isdir
            newW = prtUtilRecursiveWhat(fullfile(directory,dirList(i).name));
            W.m = cat(1,W.m,newW.m);
        end
    end
end

        
