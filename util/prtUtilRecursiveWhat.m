function W = prtUtilRecursiveWhat(directory)

dirList = dir(directory);
W = what(directory);

for i = 3:length(dirList)  %skip '.', '..'
    if dirList(i).isdir
        newW = prtUtilRecursiveWhat(fullfile(directory,dirList(i).name));
        W.m = cat(1,W.m,newW.m);
    end
end

        