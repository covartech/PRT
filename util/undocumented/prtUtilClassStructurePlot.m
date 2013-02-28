function varargout = prtUtilClassStructurePlot(classNamesStrCell)
% h = prtUtilClassStructurePlot(classNamesStrCell);
%
% Mostly Ripped from viewClassTree() from MATLAB central by Matthew Dunham.
%
% View a class inheritence hierarchy. All classes residing in the directory
% or any subdirectory are discovered. Parents of these classes are also
% discovered as long as they are in the matlab search path.
% There are a few restrictions:
% (1) classes must be written using the new 2008a classdef syntax
% -This is no longer true-(2) classes must reside in their own @ directories.
% (3) requires the bioinformatics biograph class to display the tree.
% (4) works only on systems that support 'dir', i.e. windows.
%
%Written by Matthew Dunham

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


suppliedDir = false;
if nargin == 0
    directory = pwd;
    suppliedDir = true;
elseif ischar(classNamesStrCell)
    if isdir(classNamesStrCell)
        directory = classNamesStrCell;
        suppliedDir = true;
    else
        classNamesStrCell = {classNamesStrCell};
    end
end


if suppliedDir
    %fileNames = what(directory);
    fileNames = prtUtilRecursiveWhat(directory);
    classNamesStrCell = cellfun(@(c)c(1:end-2), fileNames.m,'uniformOutput',false);
end

allClasses = classNamesStrCell;
for c=1:numel(classNamesStrCell)
    allClasses = union(allClasses,ancestors(classNamesStrCell{c}));
end

matrix = zeros(numel(allClasses));
map = struct;
for i=1:numel(allClasses)
    map.(allClasses{i}) = i;
end

keepClass = false(numel(allClasses),1);
for i=1:numel(allClasses)
    try
        meta = eval(['?',allClasses{i}]);
        parents = meta.SuperClasses;
        if ~isempty(meta)
            keepClass(i) = true;
        end
    catch ME %#ok
        warning('CLASSTREE:discoveryWarning',['Could not discover information about class ',allClasses{i}]);
        continue;
    end
    for j=1:numel(parents)
        matrix(map.(allClasses{i}),map.(parents{j}.Name)) = 1;
    end
end

matrix = matrix(keepClass,keepClass);
allClasses = allClasses(keepClass);

if isscalar(matrix)
    matrix = 1;
end
h = biograph(matrix',allClasses);

% Nodes = get(h,'Nodes');
% for iN = 1:length(Nodes)
%     set(Nodes(iN),'label',allClasses{iN} );
% end
% set(h,'ShowTextInNodes','label')

view(h);

varargout = {};
if nargout
    varargout = {h};
end
end

function info = dirinfo(directory)
%Recursively generate an array of structures holding information about each
%directory/subdirectory beginning, (and including) the initially specified
%parent directory.
info = what(directory);
flist = dir(directory);
dlist =  {flist([flist.isdir]).name};
for i=1:numel(dlist)
    dirname = dlist{i};
    if(~strcmp(dirname,'.') && ~strcmp(dirname,'..'))
        info = [info, dirinfo([directory,'\',dirname])]; %#ok
    end
end
end

function list = ancestors(class)
%Recursively generate a list of all of the superclasses, (and superclasses
%of superclasses, etc) of the specified class.
list = {};
try
    meta = eval(['?',class]);
    parents = meta.SuperClasses;
catch %#ok
    return;
end
for p=1:numel(parents)
    if(p > numel(parents)),continue,end %bug fix for version 7.5.0 (2007b)
    list = [parents{p}.Name,ancestors(parents{p}.Name)];
end
end
