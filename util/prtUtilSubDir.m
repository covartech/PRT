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
%       includeDirectoriesInOutput (true)
%
% [outputList,outputStruct] = prtUtilSubDir(...) Also output the structure
%   (as from DIR) for each file found.

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

if nargin < 2
    fileMatch = '*';
end

p = inputParser;
p.addParameter('dirMatch','*');
p.addParameter('recurse',true);
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
    for ind = 1:length(subDirectoryList)
        newDir = fullfile(directory,subDirectoryList(ind).name);
        [cList,cStruct] = prtUtilSubDir(newDir,fileMatch,varargin{:});
        outputList = cat(1,outputList,cList);
        outputStruct = cat(1,outputStruct,cStruct);
    end
end
outputList = [outputList;cellfun(@(x)fullfile(directory,x),{fileList.name}','uniformoutput',false)];
outputStruct = fileList(:);