function copyrightString = prtUtilGetCurrentCopyrightString(copyVer)

if nargin < 1
    copyVer = inf; %current
end
if copyVer <= 1
    copyrightString = '% Copyright (c) 2013 New Folder Consulting';
else
    copyrightString = '% Copyright (c) 2014 CoVar Applied Technologies';
end