function prtUtilClassStructurePlot(classNamesStrCell)
% prtUtilClassStructurePlot(classNamesStrCell);
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
else
    classNamesStrCell = {class(classNamesStrCell)};
    suppliedDir = false;
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
allClasses = unique(allClasses);

matrix = zeros(numel(allClasses));
map = struct;
for i=1:numel(allClasses)
    map.(allClasses{i}) = i;
end

keepClass = false(numel(allClasses),1);
for i=1:numel(allClasses)
    try
        m = eval(['?',allClasses{i}]);
        %m = meta(allClasses{i});
        parents = m.SuperClasses;
        if ~isempty(m)
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

plotGraph(matrix, allClasses) 

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

function list = ancestors(className)
%Recursively generate a list of all of the superclasses, (and superclasses
%of superclasses, etc) of the specified class.
list = {};

try
    m = eval(['?',className]);
    parents = m.SuperclassList;
catch %#ok
    disp('error')
    return;
end

list = getAncestorsFromMeta(parents);

list = unique(list);

end

function list = getAncestorsFromMeta(m)
list = {};

for p = 1:numel(m)
    if(p > numel(m)),continue,end %bug fix for version 7.5.0 (2007b)
    list = cat(2, list, {m(p).Name}, getAncestorsFromMeta(m(p).SuperclassList));
end
end

function plotGraph(connectivity, nodeStrs) 

% plotGraph a simple quick plot of the graph layout for validation.

% Call GraphViz to get a good layout - Call the MATLAB version
graphLayoutInfo = prtPlotUtilGraphVizRun(connectivity');

% Plot each node as a box with a string of it's actionId
nNodes = length(graphLayoutInfo.Nodes);
for iNode = 1:nNodes
    cN = graphLayoutInfo.Nodes(iNode);
    
    cNHandles.rect = rectangle('Position',[cN.x cN.y cN.w cN.h]);
    cNHandles.text = text(cN.x+cN.w/2,cN.y+cN.h/2, nodeStrs{iNode}, 'VerticalAlignment','Middle','HorizontalAlignment','Center','Interpreter','none');
    
    if iNode == 1
        nodeHandles = repmat(cNHandles,nNodes,1);
    else
        nodeHandles(iNode) = cNHandles;
    end
end

% Get the scale of the axes so we know how big to make arrow heads
v = axis;
scale = mean([v(2)-v(1),v(4)-v(3)]);

% Plot each edge
nEdges = length(graphLayoutInfo.Edges);
for iEdge = 1:nEdges
    cE = graphLayoutInfo.Edges(iEdge);
    
    cStartN = graphLayoutInfo.Nodes(cE.startIndex);
    cStopN = graphLayoutInfo.Nodes(cE.stopIndex);
    
    cArrowStart = cat(2,cStartN.x + cStartN.w/2, cStartN.y + cStartN.h);
    cArrowStop = cat(2,cStopN.x + cStopN.w/2, cStopN.y);
    
    cEHandles.arrow = prtPlotUtilPlotArrow(cat(1,cArrowStart(1),cArrowStop(1)), cat(1,cArrowStart(2),cArrowStop(2)), [],'headWidth',0.01*scale,'realHeadLength',0.01*scale);
    
    if iNode == 1
        edgeHandles = repmat(cEHandles,nEdges,1);
    else
        edgeHandles(iNode) = cEHandles;
    end
end

set(gca,'XTick',[],'YTick',[]);
end

