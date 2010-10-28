function Obj = prtUtilAssignStringValuePairs(Obj,varargin)
% Internal function
% xxx Need Help xxx
if isempty(varargin)
    return
end

if mod(length(varargin), 2)
    error('prt:prtUtilAssignStringValuePairs:InvalidInput','Additional inputs must be supplied by as string/value pairs');
end

paramStrs = varargin(1:2:end);
paramVals = varargin(2:2:end);

if ~iscellstr(paramStrs)
    error('prt:prtUtilAssignStringValuePairs:InvalidInput','Additional inputs must be supplied by as string/value pairs');
end


% Get available propert names
% Note you cant just use
% >> propNames = properties(Obj);
% Because this does not include hidden properties
ObjMeta = metaclass(Obj);
propNames = cellfun(@(c)c.Name,ObjMeta.Properties,'uniformoutput',false);
setAccesses = cellfun(@(c)c.SetAccess,ObjMeta.Properties,'uniformoutput',false);
availableToBeSet = strcmpi(setAccesses,'public');
propNames = propNames(availableToBeSet);

for iPair = 1:length(paramStrs)
    cParamName = paramStrs{iPair};
    
    cParamNameRealInd = find(strcmpi(propNames,cParamName));
    if isempty(cParamNameRealInd)
        error('prt:prtUtilAssignStringValuePairs','No public field %s exists for class %s',cParamName, ObjMeta.Name);
    end
    
    cParamNameReal = propNames{cParamNameRealInd};
    
    Obj.(cParamNameReal) = paramVals{iPair};
end