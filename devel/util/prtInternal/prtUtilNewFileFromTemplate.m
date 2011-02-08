function prtUtilNewFileFromTemplate(defaultFileName,preferredMfilePrefix,templateFile,varargin)
%prtUtilNewFileFromTemplate(defaultFileName,preferredMfilePrefix,templateFile,varargin)
%
%   Prompt the user for a file that starts with defaultFileName.
%
%   Copy templateFile into defaultFileName, and replace any occuracnes of
%   <fileName> with the user-specified filename and <className> with the
%   class name inferred from the file name (if possible).
%
%   prtNewFileFromTemplate(defaultFileName,templateFile,find1,replace1,find2,replace2,...)
%       Also replace any occurances of find# with the string replace#.
%    

%Get the file to write:
[fileName,className,success] = prtUtilUiputMfile(defaultFileName,preferredMfilePrefix);
if ~success
    return;
end

%Copy the template file into the M-file, and replace strings:
[~,fileWithoutExtention] = fileparts(fileName);
prtUtilTemplateFileCopyAndStringReplace(templateFile,fileName,'<fileName>',fileWithoutExtention,'<className>',className,varargin{:});

%Show the user:
edit(fileName);
