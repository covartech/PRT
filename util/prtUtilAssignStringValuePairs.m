function Obj = prtUtilAssignStringValuePairs(Obj,varargin)

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

for iPair = 1:length(paramStrs)
    Obj.(paramStrs{iPair}) = paramVals{iPair};
end