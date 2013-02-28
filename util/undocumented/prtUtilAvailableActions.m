function ActionStruct = prtUtilAvailableActions
% xxx Need Help xxx?
% Internal function?

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


%%
% All m files in the prt
prtMFiles = prtUtilRecursiveDir(prtRoot,'*.m');

% Remove path information leaving just the file name
[~, prtMFileNames] = cellfun(@(s)fileparts(s),prtMFiles,'uniformoutput',false);

% Test each m file to see if it is a class
isClass = cellfun(@(s)exist(s,'class')==8,prtMFileNames);
prtClassFiles = prtMFileNames(isClass);

% Test each class to see if it is a prtAction
iAction = 1;
for iClassType = 1:length(prtClassFiles)
    %cMeta = meta.class.fromName(prtClassFiles{iClassType});
    
    %
    cStruct = prtUtilClassParentRelationshipNamesOnly(prtClassFiles{iClassType});
    
    if any(strcmpi('prtAction',cStruct.classNames))
        ClassInfoStructs(iAction,1) = cStruct;
        iAction = iAction + 1;
    end
end

actionClassNames = arrayfun(@(S)S.classNames{1},ClassInfoStructs,'uniformoutput',false);

parentIndicator = false(numel(actionClassNames));
map = struct;
for i=1:numel(actionClassNames)
    map.(actionClassNames{i}) = i;
end

for i=1:numel(actionClassNames)
    cMeta = meta.class.fromName(actionClassNames{i});
    parents = cMeta.SuperClasses;
    for j=1:numel(parents)
        parentIndicator(map.(actionClassNames{i}),map.(parents{j}.Name)) = true;
    end
end

%%

% Manually Locate Root node. Then find Children.
ActionStruct(1,1).index = find(~any(parentIndicator,2));
ActionStruct(1,1).name = actionClassNames{ActionStruct(1,1).index};
ActionStruct(1,1).Info = ClassInfoStructs(ActionStruct(1,1).index);
ActionStruct(1,1).childrenInds = find(parentIndicator(:, ActionStruct(1,1).index));
%ActionStruct(1,1).Children = find(parentIndicator(:, ActionStruct(1,1).index));
ActionStruct.Children = findChildren(ActionStruct(1,1).index, parentIndicator, actionClassNames, ClassInfoStructs);

end

function Children = findChildren(index, parentIndicator,actionClassNames, ClassInfoStructs)

    childrenInds = find(parentIndicator(:, index));
    Children = [];
    for iChild = 1:length(childrenInds)
        Children(iChild,1).index = childrenInds(iChild);    
        Children(iChild,1).name = actionClassNames{Children(iChild,1).index};
        Children(iChild,1).Info = ClassInfoStructs(Children(iChild,1).index);
        Children(iChild,1).childrenInds = find(parentIndicator(:, Children(iChild,1).index));
        
        Children(iChild,1).Children = findChildren(Children(iChild,1).index, parentIndicator, actionClassNames, ClassInfoStructs);
        
        % For Each Child. Try to find the children.
        for iSubChild = 1:length(Children(iChild,1).childrenInds)
            if ~isempty(Children(iChild,1).Children(iSubChild).childrenInds)
                Children(iChild,1).Children(iSubChild).Children = findChildren(Children(iChild,1).childrenInds(iSubChild), parentIndicator, actionClassNames, ClassInfoStructs);
            end
        end
    end
end
