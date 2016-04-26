function [Properties, Methods] = prtUtilClassParentRelationshipTable(className)
% xxx Need Help xxx
% Internal 





Info = prtUtilClassParentRelationship(className);


Properties.names = cell(size(Info.AllProperties));
for iProp = 1:numel(Info.AllProperties)
    if isempty(Info.AllProperties{iProp})
        Properties.names{iProp} = '';
    else
        Properties.names{iProp} = Info.AllProperties{iProp}.Name;
    end
end
Properties.classNames = Info.classNames;


Methods.names = cell(size(Info.AllMethods));
for iMeth = 1:numel(Info.AllMethods)
    if isempty(Info.AllMethods{iMeth})
        Methods.names{iMeth} = '';
    else
        Methods.names{iMeth} = Info.AllMethods{iMeth}.Name;
    end
end
Methods.classNames = Info.classNames;

uitable('Data',Properties.names,'ColumnName',Properties.classNames,'Units','Normalized','Position',[0 0.5 1 0.5]);
uitable('Data',Methods.names,'ColumnName',Methods.classNames,'Units','Normalized','Position',[0 0 1 0.5]);
