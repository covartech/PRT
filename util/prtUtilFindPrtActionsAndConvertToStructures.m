function cVal = prtUtilFindPrtActionsAndConvertToStructures(cVal)







if isa(cVal,'prtAction')
    cVal = cVal.toStructure;
elseif iscell(cVal)
    % Current element is a cell that may contain prtActions
    for iCell = 1:numel(cVal)
        cVal{iCell} = prtUtilFindPrtActionsAndConvertToStructures(cVal{iCell});
    end
elseif isstruct(cVal)
    subFieldNames = fieldnames(cVal);
    for iField = 1:length(subFieldNames)
        cVal.(subFieldNames{iField}) =  prtUtilFindPrtActionsAndConvertToStructures(cVal.(subFieldNames{iField}));
    end
end
