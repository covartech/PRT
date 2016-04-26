function ab = prtUtilClassIsAbstract(class)
% prtUtilClassIsAbstract  Determine if a class is abstract or not
%
%  ABSTRACT = prtUtilClassIsAbstract(CLASS) returns true of the string CLASS refers to
%  an abstract class, and false otherwise.





if ~ischar(class)
    error('CLASS must be a string representing a class name')
end

mcls = meta.class.fromName(class);
ab = any([mcls.MethodList.Abstract]);
