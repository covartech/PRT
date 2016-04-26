function OutStruct = prtUtilClassParentRelationshipNamesOnly(varargin)
% prtUtilClassParentRelationship(baseClassName)
% xxx Need Help xxx
% Internal







I = meta.class.fromName(varargin{1});
if nargin == 1
    OutStruct.classNames = {I.Name};
%     OutStruct.propNames = cellfun(@(c)c.Name,I.Properties,'uniformOutput',false);
%     OutStruct.methodNames = cellfun(@(c)c.Name,I.Methods,'uniformOutput',false);
%     OutStruct.AllProperties = I.Properties;
%     OutStruct.AllMethods = I.Methods;
    
elseif nargin == 2
    OutStruct = varargin{2};
    % Add yourself to the list of class Names
    OutStruct.classNames = cat(1,OutStruct.classNames,{I.Name});
    
%     cSortedProperties = cell(length(OutStruct.propNames),1);
%     for iProp = 1:length(I.Properties)
%         %cInd = find(~cellfun(@isempty, strfind(OutStruct.propNames,I.Properties{iProp}.Name)),1);
%         cInd = find(cellfun(@(s)isequal(I.Properties{iProp}.Name,s),OutStruct.propNames),1);
%         
%         if isempty(cInd)
%             error('Maximum property assumption invalid');
%         end
%         
%         cSortedProperties{cInd} = I.Properties{iProp};
%     end
%     
%     cSortedMethods = cell(length(OutStruct.methodNames),1);
%     for iMeth = 1:length(I.Methods)
%         if strcmpi(I.Methods{iMeth}.Name,varargin{1})
%             continue
%         end
%         if strcmpi(I.Methods{iMeth}.Access,'private');
%             continue
%         end
%         
%         %cInd = find(~cellfun(@isempty, strfind(OutStruct.methodNames,I.Methods{iMeth}.Name)),1);
%         cInd = find(cellfun(@(s)isequal(I.Methods{iMeth}.Name,s),OutStruct.methodNames),1);
%         if isempty(cInd)
%             error('Maximum method assumption invalid');
%         end
%         
%         cSortedMethods{cInd} = I.Methods{iMeth};
%     end
%     
%     OutStruct.AllProperties = cat(2,OutStruct.AllProperties,cSortedProperties);
%     OutStruct.AllMethods = cat(2,OutStruct.AllMethods,cSortedMethods);
end

for iParent = 1:length(I.SuperClasses);
    OutStruct = prtUtilClassParentRelationshipNamesOnly(I.SuperClasses{iParent}.Name,OutStruct);
end

end
