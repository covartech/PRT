function ActionStruct = prtUtilAvailableActions
% xxx Need Help xxx?
% Internal function?







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
