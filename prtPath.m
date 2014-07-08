function output = prtPath(varargin)
% prtPath Adds necessary directories for the PRT to your path.
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

if isdeployed
    return;
end
startupCheck = true;
if startupCheck
    checkPrtInStartup;
end

addpath(fullfile(prtRoot,'util'));
origPath = prtUtilGenCleanPath(prtRoot);
addpath(origPath);

for iArg = 1:length(varargin)
    cArg = varargin{iArg};
    cDir = fullfile(prtRoot,cat(2,']',cArg));
    assert(logical(exist(cDir,'file')),']%s is not a directory in %s',cArg,prtRoot);
    P = prtUtilGenCleanPath(cDir,'removeDirStart',{'.'});
    addpath(P);
    origPath = cat(2,origPath,P);
end
if nargout > 0
    output = origPath;
end

function checkPrtInStartup
% checkPrtInStartup
% Warn the user if the prtPath command isn't found in their startup.m file.
%  In order for prtDoc, and the MATLAB Doc to work with the PRT, prtPath
%  must be called in STARTUP, not after MATLAB has started.

startupFile = which('startup.m');
if isempty(startupFile)
    h = warndlg('The M-file startup.m was not found on your MATLAB Path; to include all of the functionality of the PRT including HTML documentation, a startup.m file should include code to add the PRT to the MATLAB path. For more information about startup files, please see: http://www.mathworks.com/help/techdoc/ref/startup.html','prtPath: Not in startup.m');
else
    
    startupCommand = sprintf('prtPath');
    
    fid = fopen(startupFile,'r');
    s = fscanf(fid,'%c');
    fclose(fid);
    
    if isempty(strfind(lower(s),lower(startupCommand)));
        h = warndlg(sprintf('Your M-file startup.m does not seem to contain the command "%s"; to include all of the functionality of the PRT including HTML documentation, your startup.m file should include this command',startupCommand),'prtPath: Not in startup.m');
        warning('prt:prtPath:missingCommand','Your M-file startup.m does not seem to contain the command "%s".  To include all of the functionality of the PRT including HTML documentation, your startup.m file should include this command',startupCommand);
    end
end
