function prtPath
% prtPath Adds necessary directories for the PRT to your path.

P = genpath(prtRoot);
addpath(P);

%Remove some paths we don't need (we remove all directories that start with
% a . or a ~

removePath = [];
[string,remString] = strtok(P,pathsep);
while ~isempty(string);
    if ~isempty(strfind(string,[filesep '.'])) || ~isempty(strfind(string,[filesep '~']))
        removePath = cat(2,removePath,pathsep,string);
    end
    [string,remString] = strtok(remString,pathsep); %#ok
end
if ~isempty(removePath)
    rmpath(removePath);
end