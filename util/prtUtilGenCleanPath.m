function thePath = prtUtilGenCleanPath(baseDir,varargin)
%thePath = prtUtilGenCleanPath(baseDir)
%   Generate the path string starting with genpath(basedir), but ignoring
%   any directories starting with a '.' or a ']'.
%

p = inputParser;
p.addParamValue('removeDirStart',{'.',']','+'}); % In newer MATLAB addParameter is prefered but we need a little backwards compatibility
p.parse(varargin{:});
inputs = p.Results;

thePath = genpath(baseDir);
[string,remString] = strtok(thePath,pathsep);
while ~isempty(string);
    removeThisDir = false;
    for i = 1:length(inputs.removeDirStart)
        removeThisDir = removeThisDir || ~isempty(strfind(string,[filesep inputs.removeDirStart{i}]));
    end
    if removeThisDir
        thePath = strrep(thePath,cat(2,string,pathsep),'');
    end
    [string,remString] = strtok(remString,pathsep); %#ok
end
