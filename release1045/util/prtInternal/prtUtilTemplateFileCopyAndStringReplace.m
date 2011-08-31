function prtUtilTemplateFileCopyAndStringReplace(templateFile,writeFile,varargin)
% prtUtilTemplateFileReplace(templateFile,writeFile,varargin)

if ~exist(templateFile,'file')
    error('prtUtilTemplateFileCopyAndStringReplace:missingTemplate','The template file %s was not found.',templateFile);
end
fid = fopen(templateFile,'r');
templateFileString = fscanf(fid,'%c');
fclose(fid);


for i = 1:2:length(varargin)
    templateFileString = strrep(templateFileString,varargin{i},varargin{i+1});
end

fid = fopen(writeFile,'w');
if fid == -1
    error('prtUtilTemplateFileCopyAndStringReplace:CannotOpenFile','Error opening file %s for writing.  File not found, or permission denied',fullMfile);
end
fwrite(fid,templateFileString);
fclose(fid);
