function success = prtNewClass(defaultFileName)
% PRTNEWCLASS creates a new prtClass* M-file
%
%   PRTNEWCLASS creates a new prtClass* M-file including definitions for
%   all required methods and properties for prtClass objects.  By
%   convention, prtClass M-files should start with the string prtClass, and
%   file names must be valid MATLAB function names (no special characters,
%   spaces, etc.)
%
%   PRTNEWCLASS(FILENAME) enables the user to specify the name of the new
%   prtClass object from the command line.
%
%   %Example:
%   prtNewClass('prtClassAwesome');
%

if nargin < 1
    defaultFileName = 'prtClass*.m';
end

templateFile = fullfile(prtRoot,'engine','prtObjectCreation','templates','prtNewClassTemplate.temp');
if ~exist(templateFile,'file')
    error('prtNewClass:missingTemplate','The template file %s was not found.',templateFile);
end
fid = fopen(templateFile,'r');
templateFileString = fscanf(fid,'%c');
fclose(fid);

%get a file name that:
%   1) Is a valid MATLAB function/class name
%   2) Has a .m extention
%   3) Starts with the string 'prtClass'
%
%  Note: we can make this a subfunction to be used in prtNew* functions
%  prtUtilUiputClassFile(defaultFileName,providedFileName,objectType,preferredObjectTypePrefix)
%
fileName = nan;
pathName = nan;
isValidFileName = false;
while ~isValidFileName
    
    if ~isnan(fileName);
        if ~isvarname(fileName)
            errorHandle = errordlg(sprintf('The file name provided (%s) is not a valid MATLAB Class name',fileName), 'Invalid File', 'modal');
            uiwait(errorHandle);
        elseif ~strcmpi(fileExtension,'.m')
            errorHandle = errordlg(sprintf('The file extension used (%s) does not match ''.m''',fileExtension), 'Invalid File Extension', 'modal');
            uiwait(errorHandle);
        elseif strcmpi(fileName,'prtClass');
            errorHandle = errordlg(sprintf('Attempt to write an M-file called ''prtClass''; this will conflict with the prt M-file prtClass'), 'prtClass Conflict', 'modal');
            uiwait(errorHandle);
        end
    end
    [fileNameWithExtension, pathName] = uiputfile('*.m', 'prtClass M-file',defaultFileName);
    if isequal(fileName,0) || isequal(pathName,0)
        if nargout > 0
            success = 0;
            file = nan;
        end
        return;
    end
    [~,fileName,fileExtension] = fileparts(fileNameWithExtension);
    isValidFileName = isvarname(fileName) && strcmpi(fileExtension,'.m') && ~strcmpi(fileName,'prtClass');
    
    if length(fileName) < 8 || ~strcmpi(fileName(1:8),'prtClass')
        warnHandle = warndlg(sprintf('The file name provided (%s) does not start with ''prtClass'', by convention prt classifier objects are recommended to start with the string ''prtClass''; the PRT will not be able to infer the name of this Classifier from the name of the M-file',fileName),'Non prtClass* File name','modal');        uiwait(warnHandle)
        className = 'unknown';
    else
        className = fileName(9:end);
    end
    
    S = which(fileName);
    if ~isempty(S)
        if iscell(S)
            S = S{1};
        end
        answer = questdlg(sprintf('The file name provided (%s) will shadow the M-file %s on the MATLAB path; Continue?',fileName,S),'M-file Name Shadows','Yes, Continue (Shadow M-file)','No, choose a new name','No, choose a new name');
        switch lower(answer)
            case lower('No, choose a new name')
                isValidFileName = false;
        end
    end
end

fileString = strrep(templateFileString,'<fileName>',fileName);
fileString = strrep(fileString,'<className>',className);


fullMFile = fullfile(pathName,fileNameWithExtension);
%Check for conflicts:  (actually, uiputfile does this...
% if exist(fullMFile,'file')
%     ButtonName = questdlg(sprintf('The M-file specified (%s) already exists.  Overwrite?',fileNameWithExtension), ...
%         'File already exists', ...
%         'Yes, overwrite existing file','No, cancel file creation','No, cancel file creation');
%     switch lower(ButtonName)
%         case lower('No, cancel file creation')
%             if nargout > 0
%                 success = 0;
%                 file = nan;
%             end
%             return;
%     end
% end

%Otherwise, go for it:
fid = fopen(fullMFile,'w');
fwrite(fid,fileString);
fclose(fid);
edit(fullMFile);

success = 1;