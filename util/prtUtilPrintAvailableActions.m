function prtUtilPrintAvailableActions(ActionStruct,layer)
% Internal
% xxx Need Help xxx







if nargin < 1 || isempty(ActionStruct)
    ActionStruct = prtUtilAvailableActions;
end
if nargin < 2 || isempty(layer)
    layer = 0;
end

for iName = 1:length(ActionStruct)
    fprintf(cat(2,repmat('\t',1,layer),'%s\n'),ActionStruct(iName).name);
    if ~isempty(ActionStruct(iName).Children)
        for iChild = 1:length(ActionStruct(iName).Children);
            prtUtilPrintAvailableActions(ActionStruct(iName).Children(iChild),layer+1)
        end
    end
end
