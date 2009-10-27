function Properties = prtUtilClassParentRelationshipTable(className)

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

uitable('Data',Properties.names,'ColumnName',Properties.classNames,'Units','Normalized','Position',[0 0 1 1]);