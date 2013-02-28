function [fileNameWithExtension,className,success] = prtUtilUiputMfile(defaultFileName,preferredMfilePrefix)
%[fileName,className,success] = prtUtilUiputMfile(defaultFileName)
%
%prompt the user to specify a file to create that:
%   1) Is a valid MATLAB function/class name
%   2) Has a .m extention
%   3) Starts with the string defaultFileName
%

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


%By default, append *.m
if strcmpi(preferredMfilePrefix,defaultFileName);
    defaultFileNameFull = cat(2,defaultFileName,'*.m');
else
    defaultFileNameFull = defaultFileName;
    %the user provided a different string to use for uiputfile; trust them
end

fileName = nan;
isValidFileName = false;
success = 0;
while ~isValidFileName
    
    %Explain to the user why this isn't a valid M-file name; either it
    %contains invalid characters, or doesn't end with .m.  The first time
    %through, fileName should be NaN, we don't warn that time:
    if ~isnan(fileName);
        if ~isvarname(fileName)
            errorHandle = errordlg(sprintf('The file name provided (%s) is not a valid MATLAB Class name',fileName), 'Invalid File', 'modal');
            uiwait(errorHandle);
        elseif ~strcmpi(fileExtension,'.m')
            errorHandle = errordlg(sprintf('The file extension used (%s) does not match ''.m''',fileExtension), 'Invalid File Extension', 'modal');
            uiwait(errorHandle);
        end
    end
    
    %Get the file name the user wants, and handle user cancellation
    %gracefully:
    [fileNameWithExtension, pathName] = uiputfile('*.m', sprintf('%s M-file',defaultFileName),defaultFileNameFull);
    if isequal(fileName,0) || isequal(pathName,0)
        if nargout > 0
            fileNameWithExtension = nan;
            className = nan;
            success = 0;
        end
        return;
    end
    
    %Parse the file name, check validity, and check default M-file prefix
    %string:
    [~,fileName,fileExtension] = fileparts(fileNameWithExtension);
    isValidFileName = isvarname(fileName) && strcmpi(fileExtension,'.m');
    
    if length(fileName) < length(preferredMfilePrefix) || ~strcmpi(fileName(1:length(preferredMfilePrefix)),preferredMfilePrefix)
        warnHandle = warndlg(sprintf('The file name provided (%s) does not start with ''%s'', by convention %s objects are recommended to start with the string ''%s''; the PRT will not be able to infer the name of this object from the name of the M-file',fileName,preferredMfilePrefix,preferredMfilePrefix,preferredMfilePrefix),sprintf('Non %s* File name','modal',preferredMfilePrefix));        uiwait(warnHandle)
        className = 'unknown';
    else
        className = fileName(length(defaultFileName)+1:end);
    end
    
    % If the file is on the MATLAB path already; warn about shadowing.  The
    % exception is if the new file is actually replacing the file that's on
    % the MATLAB path. If that's the case, don't warn; the user has already
    % been warned when choosing the file.
    S = which(fileName);
    if ~isempty(S) && ~strcmpi(S,fileNameWithExtension);
        answer = questdlg(sprintf('The file name provided (%s) will shadow the M-file %s on the MATLAB path; Continue?',fileName,S),'M-file Name Shadows','Yes, Continue (Shadow M-file)','No, choose a new name','No, choose a new name');
        switch lower(answer)
            case lower('No, choose a new name')
                isValidFileName = false;
        end
    end
end
success = 1;
