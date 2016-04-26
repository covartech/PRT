function Obj = prtUtilAssignStringValuePairs(Obj,varargin)
% prtUtilAssignStringValuePairs - Assings string value pairs to Matlab
% objects
% 
% This function is used in the constructor of many PRT objects to enable
% string value pairs to be input to the object.
% This function ensures that a public field exists for each of those being
% set to the object.
%
% Obj = prtUtilAssignStringValuePairs(Obj,paramName1,paramVal1,paramName2,paramVal2,...)







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


% Get available property names
if isstruct(Obj)
	propNames = fieldnames(Obj);
else
	% Note you cant just use
	% >> propNames = properties(Obj);
	% Because this does not include hidden properties
	ObjMeta = metaclass(Obj);
	propNames = cellfun(@(c)c.Name,ObjMeta.Properties,'uniformoutput',false);
	setAccesses = cellfun(@(c)c.SetAccess,ObjMeta.Properties,'uniformoutput',false);
	availableToBeSet = strcmpi(setAccesses,'public');
	propNames = propNames(availableToBeSet);
end

for iPair = 1:length(paramStrs)
    cParamName = paramStrs{iPair};
    
    cParamNameRealInd = find(strcmpi(propNames,cParamName));
    if isempty(cParamNameRealInd)
        error('prt:prtUtilAssignStringValuePairs','No public field %s exists for class %s',cParamName, ObjMeta.Name);
    end
    
    cParamNameReal = propNames{cParamNameRealInd};
    
    Obj.(cParamNameReal) = paramVals{iPair};
end
