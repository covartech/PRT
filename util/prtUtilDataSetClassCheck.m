function tf = prtUtilDataSetClassCheck(proposedDataSetClass, dataSetRequirement)
% tf = prtUtilDataSetClassCheck(proposedDataSetClass, dataSetRequirement)
% Determines whether proposedDataSetClass is acceptable to use as input to
% prtAction that states that dataSetRequirement is require for input







assert(ischar(proposedDataSetClass) && ischar(dataSetRequirement),'prt:prtUtilDataSetClassCheck','inputs must be strings');

% Quick exit, same thing
if isequal(proposedDataSetClass,dataSetRequirement)
    tf = 1;
    return
end

% Otherwise we need to search through the class hierarchies
SubProps = meta.class.fromName(proposedDataSetClass);

superClassNames = spillSuperClassNames(SubProps);

tf = ismember(dataSetRequirement, superClassNames);

function superClassNames = spillSuperClassNames(SubProps)

superClassNames = {SubProps.Name};
for iSuper = 1:length(SubProps.SuperClasses)
    cSuperClassNames = spillSuperClassNames(SubProps.SuperClasses{iSuper});
    superClassNames = cat(1,cSuperClassNames(:),superClassNames(:));
end
