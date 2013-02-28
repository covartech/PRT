function prtUtilApplyLicense(fileName)

fid = fopen(fileName);
s = textscan(fid,'%s');
fclose(fid);

licenseStr = prtUtilLicense;

keyboard