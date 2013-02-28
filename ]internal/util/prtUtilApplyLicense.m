function prtUtilApplyLicense(fileName)
% prtUtilApplyLicense(fileName)
%   Used internaly to update license information in the PRT

% g = subDir(prtRoot,'*.m');
% for i = 1:length(g); prtUtilApplyLicense(g{i}); end

if ~isempty(strfind(lower(fileName),'prtexternal'))
    [p,f] = fileparts(fileName);
    fprintf('prtExternal file ignored: %s (in %s)\n',p,f);
    return;
end
if ~isempty(strfind(lower(fileName),'prtdoc'))
    [p,f] = fileparts(fileName);
    fprintf('prtDoc file ignored: %s (in %s)\n',f,p);
    return;
end 

newStr = '';
licenseStr = prtUtilLicense;

fid = fopen(fileName);
s = fscanf(fid,'%c');
if ~isempty(strfind(lower(s),'copyright'))
    [p,f] = fileparts(fileName);
    fprintf('Copyright found in: %s (OK if it doesn''t conflict with ours)\n',f);
    %     edit(fileName);
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