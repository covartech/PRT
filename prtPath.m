function prtPath(varargin)
% prtPath Adds necessary directories for the PRT to your path.
%

startupCheck = true;
if startupCheck
    checkPrtInStartup;
end

P = genpath(prtRoot);
addpath(P);

%Remove some paths we don't need (we remove all directories that start with
% a . or a ~

removePath = [];
[string,remString] = strtok(P,pathsep);
while ~isempty(string);
    if ~isempty(strfind(string,[filesep '.'])) || ~isempty(strfind(string,[filesep ']']))
        removePath = cat(2,removePath,pathsep,string);
    end
    [string,remString] = strtok(remString,pathsep); %#ok
end
if ~isempty(removePath)
    rmpath(removePath);
end

for iArg = 1:length(varargin)
    cArg = varargin{iArg};
    cDir = fullfile(prtRoot,cat(2,']',cArg));
    assert(logical(exist(cDir,'file')),']%s is not a directory in %s',cArg,prtRoot);
    P = genpath(cDir);
    addpath(P);
    
    removePath = [];
    [string,remString] = strtok(P,pathsep);
    while ~isempty(string);
        if ~isempty(strfind(string,[filesep '.']))
            removePath = cat(2,removePath,pathsep,string);
        end
        [string,remString] = strtok(remString,pathsep); %#ok
    end
    if ~isempty(removePath)
        rmpath(removePath);
    end
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
        h = warndlg(sprintf('The M-file startup.m does not seem to contain the command "%s"; to include all of the functionality of the PRT including HTML documentation, your startup.m file should include this command',startupCommand),'prtPath: Not in startup.m');
        warning('prt:prtPath:missingCommand','The M-file startup.m does not seem to contain the command "%s".  To include all of the functionality of the PRT including HTML documentation, your startup.m file should include this command',startupCommand);
    end
end