% prtUpdateAllMfileLicenses

fList = prtUtilSubDir(prtRoot,'*.m');

for i = 1:length(fList)
    prtUtilRemoveOldLicense(fList,true);
    prtUtilApplyLicense(fList,true);
end