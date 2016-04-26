function [outputList,outputStruct] = prtUtilSubDir(directory,fileMatch,varargin)
% list = prtUtilSubDir(directory,match)
%   Return all the files in directory (and all sub-directories) matching
%   the file-specification "match".
%
%   list = prtUtilSubDir(matlabroot,'*.txt');
%
% list = prtUtilSubDir(directory,match,varargin)
%   Enables specification of additional parameters:
%       dirMatch (*)
%       recurse (true)
%       includeDirectoriesInOutput (true) - true, false, or 'only'
%
% [outputList,outputStruct] = prtUtilSubDir(...) Also output the structure
%   (as from DIR) for each file found.






if nargin < 2
    fileMatch = '*';
end

p = inputParser;
p.addParameter('dirMatch','*');
p.addParameter('recurse',true);
p.addParameter('waitbar',false);
p.addParameter('includeDirectoriesInOutput',true);

p.parse(varargin{:});
inputStruct = p.Results;

dirMatch = inputStruct.dirMatch;
recurse = inputStruct.recurse;

subDirectoryList = dir(fullfile(directory,dirMatch));
% Remove . and ..
subDirectoryList = subDirectoryList(~arrayfun(@(x)ismember(x.name,{'.';'..'}),subDirectoryList));
subDirectoryList = subDirectoryList(arrayfun(@(x)x.isdir,subDirectoryList));

%Why remove directories?!
fileList = dir(fullfile(directory,fileMatch));
fileList = fileList(~arrayfun(@(x)ismember(x.name,{'.';'..'}),fileList));
if isa(inputStruct.includeDirectoriesInOutput,'char') && strcmpi(inputStruct.includeDirectoriesInOutput,'only')
    fileList = fileList([fileList.isdir]);
elseif isa(inputStruct.includeDirectoriesInOutput,'char') 
    error('prtUtilSubDir:invalidOutputSpec','Character includeDirectoriesInOutput must be ''only''');
elseif ~inputStruct.includeDirectoriesInOutput
    fileList = fileList(~[fileList.isdir]);
end

outputList = {};
outputStruct = [];
if recurse
    if inputStruct.waitbar
        cDir = strrep(directory(max(end-40,1):end),filesep,'-');
        waitHandle = prtUtilProgressBar(0,sprintf('Searcing directory: %s',cDir));
    end
    for ind = 1:length(subDirectoryList)
        if inputStruct.waitbar
            waitHandle.update(ind./length(subDirectoryList));
        end
        newDir = fullfile(directory,subDirectoryList(ind).name);
        [cList,cStruct] = prtUtilSubDir(newDir,fileMatch,varargin{:});
        outputList = cat(1,outputList,cList);
        outputStruct = cat(1,outputStruct,cStruct);
    end
    
    if inputStruct.waitbar
        waitHandle.update(1);
    end
end
outputList = [outputList;cellfun(@(x)fullfile(directory,x),{fileList.name}','uniformoutput',false)];
outputStruct = fileList(:);
