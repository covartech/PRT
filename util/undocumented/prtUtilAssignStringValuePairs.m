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
