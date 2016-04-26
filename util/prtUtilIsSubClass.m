function tf = prtUtilIsSubClass(proposedSubClass,proposedSuperClass)
% PRTUTILISSUBCLASS Determine if a class is a subclass of another
%   Reports true for inputs of the same class
%
% tf = prtUtilIsSubClass(proposedSubClassName,proposedSuperClassName)
%
% Inputs must be strings not instances of the class







assert(ischar(proposedSubClass) && ischar(proposedSuperClass),'prt:prtUtilIsSubClass','inputs must be strings');

% Quick exit, same thing
if isequal(proposedSubClass,proposedSuperClass)
    tf = 1;
    return
end

% Otherwise we need to search through the class hierarchies
SubProps = meta.class.fromName(proposedSubClass);

superClassNames = spillSuperClassNames(SubProps);

tf = ismember(proposedSuperClass, superClassNames);

function superClassNames = spillSuperClassNames(SubProps)

superClassNames = {SubProps.Name};
for iSuper = 1:length(SubProps.SuperClasses)
    cSuperClassNames = spillSuperClassNames(SubProps.SuperClasses{iSuper});
    superClassNames = cat(1,cSuperClassNames(:),superClassNames(:));
end
