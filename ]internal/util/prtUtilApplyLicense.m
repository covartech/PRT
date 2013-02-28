function prtUtilApplyLicense(fileName)

newStr = '';

licenseStr = prtUtilLicense;

fid = fopen(fileName);
s = fscanf(fid,'%c');
if ~isempty(strfind(lower(s),'copyright'))
    fprintf('A copyright was found in file %s\n',fileName);
    edit(fileName);
end
fclose(fid);

fid = fopen(fileName);
cLine = fgetl(fid);
newStr = cLine; %always start with the first string, now:

startFound = false;
while ~startFound & ~feof(fid);
    cLine = fgetl(fid);
    cLineDeblank = strtrim(cLine);
    
    if length(cLineDeblank) > 0 && cLineDeblank(1) == '%';
        startFound = false;
        newStr = sprintf('%s\n%s',newStr,cLine);
    else
        startFound = true;
        if length(cLineDeblank) == 0
            cLine = '';
        end
    end
end
newStr = sprintf('%s\n\n%s\n%s\n',newStr,licenseStr,cLine);

while ~feof(fid)
    cLine = fgetl(fid);
    newStr = sprintf('%s\n%s',newStr,cLine);
end
newStr = sprintf('%s\n',newStr);

fclose(fid);

[p,f] = fileparts(fileName);
fOut = fullfile('C:\Users\Pete\Documents\MATLAB\toolboxes\nfPrt\test',[f,'.m']);
fidOut = fopen(fOut,'w');
fprintf(fidOut,'%s',newStr);
fclose(fidOut);