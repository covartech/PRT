function S = prtUtilAvailableActions
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
    
    cStruct = prtUtilClassParentRelationship(prtClassFiles{iClassType});
    if any(strcmpi('prtAction',cStruct.classNames))
        ClassInfoStructs(iAction,1) = cStruct;
        iAction = iAction + 1;
    end
end

%%

actionClassNames = arrayfun(@(S)S.classNames{1},ClassInfoStructs,'uniformoutput',false);
%%
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

% parentIndicator is true if actionClassNames{j} is a (direct) parent of
% actionClassNames{i}

% For each direct parent of action 
actionInd = strcmpi('prtAction',actionClassNames);

parentIndicator(:,actionInd)

%%

actionClassLayers = arrayfun(@(S)length(S.classNames),ClassInfoStructs);

ClassInfoStructs(actionClassLayers==1) = []; % We can remove prtAction it self
actionClassLayers(actionClassLayers==1) = [];
%%
layers = actionClassLayers-1;
uLayers = unique(layers);
for iLayer = 1:length(uLayers)
    thisLayerInds = find(actionClassLayers == uLayers(iLayer));
    
end